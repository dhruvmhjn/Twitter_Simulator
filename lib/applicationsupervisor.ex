defmodule ApplicationSupervisor do
    use Supervisor
    def start_link(args) do
        return = {:ok, sup } = Supervisor.start_link(__MODULE__,args)
        start_workers(sup, args)
        return
    end
    
    def start_workers(sup, [numNodes,numRequests]) do
    
            {:ok, lispid} = Supervisor.start_child(sup, worker(Listner, [numNodes,numRequests]))     
            Supervisor.start_child(sup, supervisor(PastrySupervisor, [numNodes,numRequests,lispid]))
    
    end
    
    def init(_) do
        supervise [], strategy: :one_for_one
    end

end