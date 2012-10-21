# require 'choice'
# require 'jmx'
# require 'pry'

# jmx_queries = {
#   {
#     :result_alias => "ajp-thread-pool",
#     :name => "Catalina:type=ThreadPool,name=\"ajp-bio-8009\"",
#     :attrs => [
#                "maxHeaderCount",
#                "maxThreads",
#                "connectionCount",
#                "currentThreadCount",
#                "currentThreadsBusy"
#               ]
#   },
#   {
#     :result_alias => "http-thread-pool",
#     :name => "Catalina:type=ThreadPool,name=\"http-bio-8080\""
#     :attrs => [
#                "maxHeaderCount",
#                "maxThreads",
#                "connectionCount",
#                "currentThreadCount",
#                "currentThreadsBusy"
#               ]
#   },
#   {
#     :result_alias => "jvm-threads",
#     :name => "java.lang:type=Threading",
#     :attrs => [
#                "DaemonThreadCount",
#                "PeakThreadCount",
#                "ThreadCount",
#                "TotalStartedThreadCount"
#               ]
#   },
#   {
#     :alias => "memory",
#     :name => "java.lang:type=Memory",
#     :attrs => [ "HeapMemoryUsage", "NonHeapMemoryUsage" ]
#   },
#   {
#     :alias => "memorypool",
#     :name => "java.lang:type=MemoryPool,name=*",
#     :attrs => [ "Usage" ]
#   },
#   {
#     :alias => "gc",
#     :name => "java.lang:type=GarbageCollector,name=*",
#     :attrs => [ "CollectionCount", "CollectionTime" ]
#   },
#   {
#     :name => "Catalina:type=ThreadPool,name=*",
#     :alias => "connectors",
#     :attrs => [ "currentThreadCount", "currentThreadsBusy", "" ]
#   },
#   {
#     :name => "Catalina:type=GlobalRequestProcessor,name=*",
#     :alias => "requests",
#     :attrs => [ "bytesReceived", "bytesSent", "errorCount", "maxTime", "processingTime", "requestCount" ]
#   },
#   {  :name => "Catalina:type=DataSource,class=javax.sql.DataSource,name=*",
#     :alias  => "datasources",
#     :attrs => [ "NumActive", "NumIdle", "NumQueryThreads" ]
#   }

# }

# client = JMX.connect(:port => 3000)

# jmx_objs.each do |q|
#   client.query_names(q[:name]).flatten!.each do |jmx_obj|
#     q.attrs.each do |attr|
#       puts q[:alias] + " " + client.server.get_attribute(jmx_obj, attr.to_java_string)
#     end
#   end
# end

while true
  sleep 1
end



