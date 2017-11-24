defmodule Orc do
    use GenServer
    def start_link(numClients,timePeriod) do
        myname = String.to_atom("orc")
        return = GenServer.start_link(__MODULE__, {numClients,timePeriod}, name: myname )
        return
    end
    
    def init({numClients,timePeriod}) do
        {:ok,{numClients,timePeriod,0}}
    end

    def handle_cast({:spawn_complete},{numClients,timePeriod,numRegistered}) do
    
        n_list = Enum.to_list 1..numClients
        nodeid_list = Enum.map(n_list, fn(x) -> "user"<>x end)
        Enum.map(nodeid_list, fn(x) -> GenServer.cast(String.to_atom(x),{:register}) end)
    
    end


    # def handle_cast({:stated_s,lastnodeid},{numrequests,numnodes,numstarted,hop_counter,delivery_msgs_recieved}) do
    #     numstarted = numstarted+1
    #     if numnodes > numstarted do
    #         nextnode = "n"<>Base.encode16(:crypto.hash(:md5, Integer.to_string(numstarted+1) ) )
    #         # ADD INIT NEXT cast here 
    #         GenServer.cast(String.to_atom(nextnode),{:intialize_table,lastnodeid})
    #         #IO.puts "#{numstarted} nodes joined pastry ring."            
    #     else
    #         #IO.puts "#{numstarted} nodes joined pastry ring." 
    #         send(Process.whereis(:boss),{:network_ring_created})
    #     end
    #     {:noreply,{numrequests,numnodes,numstarted,hop_counter,delivery_msgs_recieved}}
    # end

    # def handle_cast({:delivery,no_of_hops},{numrequests,numnodes,numstarted,hop_counter,delivery_msgs_recieved}) do
    #     delivery_msgs_recieved = delivery_msgs_recieved + 1
    #     #IO.puts "hop counter: #{hop_counter}, No of hops for current: #{no_of_hops}"        
    #     #IO.puts "delivery msgs recieved: #{delivery_msgs_recieved}"
    #     hop_counter = hop_counter + no_of_hops
    #     if (delivery_msgs_recieved == (numrequests*numnodes)) do
    #         send(Process.whereis(:boss),{:all_requests_served,hop_counter})
    #     end  
    #     {:noreply,{numrequests,numnodes,numstarted,hop_counter,delivery_msgs_recieved}}
    # end
end