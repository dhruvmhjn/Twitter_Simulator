defmodule Client do
    use GenServer
    def start_link(x,_) do
        input_srt = Integer.to_string(x)
        GenServer.start_link(__MODULE__, {x}, name: String.to_atom("user#{x}"))    
    end

    def init({x}) do        
       # register self
        {:ok, {x,0}}
    end

    def handle_cast({:register},{x,act_comp})do
        #Send register request to server
        GenServer.call(:server,{:registeruser,x})
        GenServer.cast(:orc, {:registered})
        {:noreply,{x,act_comp}}
    end
    def handle_cast({:activate, subscribe_to},{x,act_comp})do
        #Subcribe to users
        #IO.puts "Client #{x} asked to activated, sub list = #{subscribe_to}"
        GenServer.cast(:server,{:subscribe,x,subscribe_to})
        #Randomly start tweeting/retweeting/subscribe/querying activities acc to zipf rank
        GenServer.cast(self,{:pick_random,1})
        {:noreply,{x,act_comp}}
    end
    def handle_cast({:pick_random,current_state},{x,act_comp}) do
        

        GenServer.cast(self,{:pick_random,current_state+1})
        {:noreply,{x,act_comp}}
    end
    def handle_cast({:deactivate},{x,act_comp})do
        #stop all activities, play dead
        #inform server
        {:noreply,{x,act_comp}}
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