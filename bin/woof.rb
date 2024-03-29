require 'choice'
require 'jmx'
require 'socket'

Choice.options do
  option :output do
    short '-o'
    long '--output=tcp'
    desc 'Destination for collected metrics'
    default 'tcp'
    valid ['stdout', 'tcp']
  end

  option :verbose do
    short '-v'
    long '--verbose'
    desc 'Verbose logging'
  end

  option :config do
    short '-c'
    long '--config'
    default File.join(File.dirname(__FILE__),'../etc/config.json')
  end
end
    
jmx_queries = [
               {
                 :alias => "ajp-thread-pool",
                 :name => "Catalina:type=ThreadPool,name=\"ajp-bio-8009\"",
                 :attrs => [
                            "maxHeaderCount",
                            "maxThreads",
                            "connectionCount",
                            "currentThreadCount",
                            "currentThreadsBusy"
                           ]
               },
               {
                 :alias => "http-thread-pool",
                 :name => "Catalina:type=ThreadPool,name=\"http-bio-8080\"",
                 :attrs => [
                            "maxHeaderCount",
                            "maxThreads",
                            "connectionCount",
                            "currentThreadCount",
                            "currentThreadsBusy"
                           ]
               },
               {
                 :alias => "jvm-threads",
                 :name => "java.lang:type=Threading",
                 :attrs => [
                            "DaemonThreadCount",
                            "PeakThreadCount",
                            "ThreadCount",
                            "TotalStartedThreadCount"
                           ]
               },
               {
                 :alias => "memory",
                 :name => "java.lang:type=Memory",
                 :attrs => [ "HeapMemoryUsage", "NonHeapMemoryUsage" ]
               },
               {
                 :alias => "memorypool",
                 :name => "java.lang:type=MemoryPool,name=*",
                 :attrs => [ "Usage" ]
               },
               {
                 :alias => "gc",
                 :name => "java.lang:type=GarbageCollector,name=*",
                 :attrs => [ "CollectionCount", "CollectionTime" ]
               },
               {
                 :name => "Catalina:type=ThreadPool,name=*",
                 :alias => "connectors",
                 :attrs => [ "currentThreadCount", "currentThreadsBusy"  ]
               },
               {
                 :name => "Catalina:type=GlobalRequestProcessor,name=*",
                 :alias => "requests",
                 :attrs => [ "bytesReceived", "bytesSent", "errorCount", "maxTime", "processingTime", "requestCount" ]
               },
               {
                 :name => "Catalina:type=DataSource,class=javax.sql.DataSource,name=*",
                 :alias  => "datasources",
                 :attrs => [ "NumActive", "NumIdle", "NumQueryThreads" ]
               }
              ]


def get_jmx_objs(name, client)
  client.query_names(name).entries
end

def get_jmx_attributes(jmx_obj, attr, client)
  attrs = client.server.get_attribute(jmx_obj, attr.to_java_string)
  if attrs.class == Java::JavaxManagementOpenmbean::CompositeDataSupport
    attrs.map{|e| [e,attrs[e]] }
  else
    [[attr, attrs]]
  end
end

def carbon_str(vals)
  updates = []
  now = Time.now.to_i
  vals.each do |k,v|
    updates << ["stats.test-jmx.#{k}", v, now].join(" ")
  end
  return updates.join("\n") + "\n"
end

client = JMX.connect(:port => 3000)

metrics = []

jmx_queries.each do |q|
  get_jmx_objs(q[:name],client).each do |jmx_obj|
    q[:attrs].each do |attr|
      jmx_vals = get_jmx_attributes(jmx_obj, attr, client)
      jmx_vals.each do |k,v|
         metrics << ["#{q[:alias]}.#{attr}.#{k}", v.to_s]
      end
    end
  end
end


# puts carbon_str(metrics)

# return 0

host = "logserver"
socket = TCPSocket.new(host, 2003)

begin
  socket.write(carbon_str(metrics))
rescue => e
  socket.close rescue nil
  socket = nil
  raise
end



