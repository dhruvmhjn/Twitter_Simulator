defmodule Orc do
    use GenServer
    def start_link(numClients,timePeriod,servernode) do
        myname = String.to_atom("orc")
        return = GenServer.start_link(__MODULE__, {numClients,timePeriod}, name: myname )
        return
    end
    def init({numClients,timePeriod}) do
        {:ok,{numClients,timePeriod,0,0}}
    end
    def handle_cast({:spawn_complete},{numClients,timePeriod,numRegistered,numCompleted}) do
    
        n_list = Enum.to_list 1..numClients

        nodeid_list = Enum.map(n_list, fn(x) -> "user"<>Integer.to_string(x) end)
        Enum.map(nodeid_list, fn(x) -> GenServer.cast(String.to_atom(x),{:register}) end)
        {:noreply,{numClients,timePeriod,numRegistered,numCompleted}}
     end

    def handle_cast({:registered},{numClients,timePeriod,numRegistered,numCompleted})do
        numRegistered = numRegistered+1
        if numRegistered == numClients do
            IO.puts "Finished registration"
            GenServer.cast(:orc,{:begin_activate})
        end
        {:noreply,{numClients,timePeriod,numRegistered,numCompleted}}
    end

    def handle_cast({:begin_activate},{numClients,timePeriod,numRegistered,numCompleted})do
        n_list = Enum.to_list 1..numClients
        sub_list = Enum.map(1..numClients, fn(_)-> Enum.map(Range.new(1,:rand.uniform(10)), fn(_)->:rand.uniform(numClients)end)end)
        Enum.map(n_list, fn(x) -> GenServer.cast(String.to_atom("user"<>Integer.to_string(x)),{:activate, Enum.uniq(Enum.at(sub_list,x-1))}) end)
        {:noreply,{numClients,timePeriod,numRegistered,numCompleted}}
    end

    def handle_cast({:acts_completed},{numClients,timePeriod,numRegistered,numCompleted}) do
        numCompleted= numCompleted + 1
        if(numCompleted == numClients) do
            :global.sync()
            send(Process.whereis(:client_boss),{:all_requests_served})
            send(Process.whereis(:server_boss),{:all_requests_served})
        end
        {:noreply,{numClients,timePeriod,numRegistered,numCompleted}}
    end
    
end