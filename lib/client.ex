defmodule Client do
    use GenServer
    def start_link(x,clients,servernode) do
        input_srt = Integer.to_string(x)
        GenServer.start_link(__MODULE__, {x,servernode}, name: String.to_atom("user#{x}"))    
    end

    def init({x,servernode}) do        
       # register self
        {:ok, {x,10,servernode}}
    end

    def handle_cast({:register},{x,acts,servernode})do
        #Send register request to server
        GenServer.call({:server,servernode},{:registeruser,x})
        GenServer.cast(:orc, {:registered})
        {:noreply,{x,acts,servernode}}
    end
    def handle_cast({:activate, subscribe_to},{x,acts,servernode})do
        #Subcribe to users
        #IO.puts "Client #{x} asked to activated, sub list = #{subscribe_to}"
        GenServer.cast({:server,servernode},{:subscribe,x,subscribe_to})
        #Randomly start tweeting/retweeting/subscribe/querying activities acc to zipf rank
        #GenServer.cast(self,{:pick_random,1})
        {:noreply,{x,acts,servernode}}
    end

    def handle_cast({:pick_random,current_state},{x,acts,servernode}) do
        if(current_state >=  acts) do
        
        else
            choice = rem(:rand.uniform()*100000,5)
             case choice do
                 1 -> subscribe(x,servernode)

                 2 ->  tweet(x,servernode)
                     #act 2

                 3 ->"three"
                     #act 3

                 4 ->"four"
                     #act 4

                 5 ->"five"
                     #act 5

                 _ -> 
                     #do nothing

             end
            GenServer.cast(self(),{:pick_random,current_state + 1})
        end
        {:noreply,{x,acts,servernode}}  
    end
    def handle_cast({:deactivate},{x,acts,servernode})do
        #stop all activities, play dead
        #inform server
        {:noreply,{x,acts,servernode}}
    end

    def tweet(x,servernode) do
        #Generate a message
        msg = "160 random characters"
        GenServer.cast({:server,servernode},{:tweet,x,msg})
    end
    def subscribe(x,servernode) do
        #Pick random user
        follow = :rand.uniform(x)
        if follow != x do
            GenServer.cast({:server,servernode},{:subscribe,x,[follow]})
        end
    end
    def query() do
        
    end
    
end