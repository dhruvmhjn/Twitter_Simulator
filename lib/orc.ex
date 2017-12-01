defmodule Orc do
    use GenServer
    def start_link(numClients,acts,subPercent,servernode) do
        myname = String.to_atom("orc")
        return = GenServer.start_link(__MODULE__, {numClients,acts,subPercent,servernode}, name: myname )
        return
    end
    def init({numClients,acts,subPercent,servernode}) do
        {:ok,{numClients,acts,subPercent,0,0,servernode}}
    end
    def handle_cast({:spawn_complete},{numClients,acts,subPercent,numRegistered,numCompleted,servernode}) do
    
        n_list = Enum.to_list 1..numClients

        nodeid_list = Enum.map(n_list, fn(x) -> "user"<>Integer.to_string(x) end)
        Enum.map(nodeid_list, fn(x) -> GenServer.cast(String.to_atom(x),{:register}) end)
        {:noreply,{numClients,acts,subPercent,numRegistered,numCompleted,servernode}}
     end

    def handle_cast({:registered},{numClients,acts,subPercent,numRegistered,numCompleted,servernode})do
        numRegistered = numRegistered+1
        if numRegistered == numClients do
            IO.puts "Finished registration"
            GenServer.cast(:orc,{:begin_activate})
        end
        {:noreply,{numClients,acts,subPercent,numRegistered,numCompleted,servernode}}
    end

    def handle_cast({:begin_activate},{numClients,acts,subPercent,numRegistered,numCompleted,servernode})do
        IO.puts "ACtivating"
        n_list = Enum.to_list 1..numClients

        sub_list = Enum.map(1..numClients, fn(_)-> Enum.map(Range.new(1,round(Float.ceil(numClients*subPercent/1000))), fn(_)-> bais(numClients) end) end)
        
        Enum.map(n_list, fn(x) -> GenServer.cast(String.to_atom("user"<>Integer.to_string(x)),{:activate, Enum.uniq(Enum.at(sub_list,x-1))}) end)
        GenServer.cast(self(),{:simulate_disconnection})
        {:noreply,{numClients,acts,subPercent,numRegistered,numCompleted,servernode}}
    end


    def handle_cast({:simulate_disconnection},{numClients,acts,subPercent,numRegistered,numCompleted,servernode}) do
        client = :rand.uniform(numClients)
        time = :rand.uniform(5)*1000
        GenServer.cast(String.to_atom("user"<>Integer.to_string(client)),{:disconnect,time})
        Process.sleep(5000)
        GenServer.cast(self(),{:simulate_disconnection})
        {:noreply,{numClients,acts,subPercent,numRegistered,numCompleted,servernode}}
    end

    def handle_cast({:acts_completed},{numClients,acts,subPercent,numRegistered,numCompleted,servernode}) do
        numCompleted= numCompleted + 1
        if(numCompleted == numClients) do
            Process.sleep(1000)
            GenServer.cast({:server,servernode},{:acts_completed})
        end
        {:noreply,{numClients,acts,subPercent,numRegistered,numCompleted,servernode}}
    end


    def bais(numClients) do
        case rem(:rand.uniform(99999),7) do
            1 ->
                :rand.uniform(round(numClients*0.1))
            2 ->
                :rand.uniform(round(numClients*0.1))
            3 ->
                :rand.uniform(round(numClients*0.6))
            4 ->
                :rand.uniform(numClients)
            5 ->
                :rand.uniform(numClients)
            _ ->
                :rand.uniform(round(numClients*0.01))
        end
    end
    
end