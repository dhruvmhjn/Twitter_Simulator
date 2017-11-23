defmodule Boss do
    def main(args) do 
        parse_args(args)
    end
    defp parse_args(args) do
        cmdarg = OptionParser.parse(args)
        {[],[numNodes,numRequests],[]} = cmdarg
        numNodesInt = String.to_integer(numNodes)
        numRequestsInt = String.to_integer(numRequests)

        #Register yourself
        Process.register(self(),:boss)
        
        ApplicationSupervisor.start_link([numNodesInt,numRequestsInt])
        
        boss_receiver(numNodesInt,numRequestsInt)
    end
            
    def boss_receiver(numNodes,numRequests) do
        receive do
            
            {:nodes_created} ->
                
                IO.puts "Pastry network init started. Waiting for nodes to join..."
                nextnode = "n"<>Base.encode16(:crypto.hash(:md5, Integer.to_string(1) ) )
                # ADD INIT NEXT cast here 
                GenServer.cast(String.to_atom(nextnode),{:intialize_table_first})

            {:network_ring_created} ->
                IO.puts "Pastry network created. Routing messages..."
                n_list = Enum.to_list 1..numNodes
                nodeid_list = Enum.map(n_list, fn(x) -> "n"<>Base.encode16(:crypto.hash(:md5, Integer.to_string(x) ) ) end)
               
                Enum.map(nodeid_list, fn(x) -> GenServer.cast(String.to_atom(x),{:create_n_requests}) end)

            {:all_requests_served,b} ->
                avg = b/(numNodes*numRequests)
                IO.puts "Total Hops: #{b}"
                IO.puts "Average Hops: #{avg}"
                :init.stop                
        end
        boss_receiver(numNodes,numRequests)
    end
end