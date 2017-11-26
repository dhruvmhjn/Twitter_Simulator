defmodule ClientSupervisor do
    use Supervisor
    def start_link([clients,time,servernode]) do
        return = {:ok,sup} = Supervisor.start_link(__MODULE__,{clients,time,servernode},[])
        start_workers(sup,clients,time,servernode)
        GenServer.cast(:orc,{:spawn_complete})
        return
    end
    def init({clients,time,servernode}) do
        n_list = Enum.to_list 1..clients
        children = Enum.map(n_list, fn(x)->worker(Client, [x,clients,servernode], [id: "client#{x}"]) end)
        supervise children, strategy: :one_for_one
    end
    def start_workers(sup,numClients,timePeriod,servernode) do
        {:ok, orcid} = Supervisor.start_child(sup, worker(Orc, [numClients,timePeriod,servernode]))                      
    end

end