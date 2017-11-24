defmodule ClientSupervisor do
    use Supervisor
    def start_link(clients,time) do
        {:ok,pid}= Supervisor.start_link(__MODULE__,{clients,time},[])
        GenServer.cast(:orc,{:spawn_complete})
        
        #send(Process.whereis(:boss),{:nodes_created})
        
        {:ok,pid}
    end
    def init({clients,time}) do
        n_list = Enum.to_list 1..clients
        children = Enum.map(n_list, fn(x)->worker(Client, [x,clients], [id: "client#{x}"]) end)
        supervise children, strategy: :one_for_one
    end
end