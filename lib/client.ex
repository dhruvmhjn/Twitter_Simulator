defmodule Client do
    use GenServer
    def start_link({x}) do
        input_srt = Integer.to_string(x)
        GenServer.start_link(__MODULE__, {x}, name: String.to_atom("user#{x}"))    
    end

    def init({x}) do        
       # register self
        {:ok, {x}}
    end

    def handle_cast({:register},{x})do
        #Send register request to server
        GenServer.call(server,{:registeruser,x})
        GenServer.cast(orc, {:registered})
        {:noreply,{x}}
    end
    def handle_cast({:activate, subscribe_to},{x})do
        #Subcribe to users
        GenServer.cast(server,{:subscribe,x,subscribe_to})
        #Randomly start tweeting/retweeting/subscribe/querying activities acc to zipf rank
        {:noreply,{x}}
    end
    def handle_cast(:deactivate},{x})do
        #stop all activities, play dead
        #inform server
        {:noreply,{x}}
    end

    def tweet() do
        #Generate a message
        msg = "160 random characters"
        GenServer.cast(server,{:tweet,x,msg})
    end
    def subscribe() do
        #Pick random user
        subscribe_to = "user1"
        GenServer.cast(server,{:subscribe,x,subscribe_to})
    end
    def query() do
        
    end
    
end