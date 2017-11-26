defmodule ApplicationSupervisor do
    use Supervisor
    def start_link(args) do
        return = {:ok, sup } = Supervisor.start_link(__MODULE__,args)
        start_workers(sup,args)
        return
    end
    def start_workers(sup, [numClients,timePeriod,clientnode]) do
            {:ok, serverid} = Supervisor.start_child(sup, worker(Server, [numClients,timePeriod,clientnode]))  
    end
    
    def init(_) do
        supervise [], strategy: :one_for_one
    end

end