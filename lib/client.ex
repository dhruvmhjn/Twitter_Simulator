defmodule Client do
    use GenServer
    def start_link(x,_) do
        input_srt = Integer.to_string(x)
        GenServer.start_link(__MODULE__, {x}, name: String.to_atom("user#{x}"))    
    end

    def init({x}) do        
       # register self
        {:ok, {x,10}}
    end

    def handle_cast({:register},{x,acts})do
        #Send register request to server
        GenServer.call(:server,{:registeruser,x})
        GenServer.cast(:orc, {:registered})
        {:noreply,{x,acts}}
    end
    def handle_cast({:activate, subscribe_to},{x,acts})do
        #Subcribe to users
        #IO.puts "Client #{x} asked to activated, sub list = #{subscribe_to}"
        GenServer.cast(:server,{:subscribe,x,subscribe_to})
        #Randomly start tweeting/retweeting/subscribe/querying activities acc to zipf rank
        #GenServer.cast(self,{:pick_random,1})
        {:noreply,{x,acts}}
    end
    def handle_cast({:pick_random,current_state},{x,acts}) do
        if(current_state >=  acts) do
        
        else
            choice = rem(:rand.uniform()*100000,5)
            cond do
                choice == 1 ->
                    #act 1
                choice == 2 ->
                    #act 2
                choice == 3 ->
                    #act 3
                choice == 4 ->
                    #act 4
                choice == 5 ->
                    #act 5
            end
            GenServer.cast(self(),{:pick_random,current_state + 1})
        end
        {:noreply,{x,act_comp}}  
    end
    def handle_cast({:deactivate},{x,acts})do
        #stop all activities, play dead
        #inform server
        {:noreply,{x,acts}}
    end

    def tweet(x) do
        #Generate a message
        msg = "160 random characters"
        GenServer.cast(:server,{:tweet,x,msg})
    end
    def subscribe(x) do
        #Pick random user
        subscribe_to = "user1"
        GenServer.cast(:server,{:subscribe,x,subscribe_to})
    end
    def query() do
        
    end
    
end