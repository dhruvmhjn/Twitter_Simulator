defmodule Client do
    use GenServer
    def start_link(x,clients,servernode,acts) do
        input_srt = Integer.to_string(x)
        GenServer.start_link(__MODULE__, {x,acts,servernode,clients}, name: String.to_atom("user#{x}"))    
    end

    def init({x,acts,servernode,clients}) do        
       # register self
        {:ok, {x,acts,servernode,clients}}
    end

    def handle_cast({:register},{x,acts,servernode,clients})do
        #Send register request to server
        GenServer.call({:server,servernode},{:registeruser,x})
        GenServer.cast(:orc, {:registered})
        {:noreply,{x,acts,servernode,clients}}
    end
    def handle_cast({:activate, subscribe_to},{x,acts,servernode,clients})do
        #Subcribe to users
        #IO.puts "Client #{x} asked to activated, sub list = #{subscribe_to}"
        GenServer.cast({:server,servernode},{:subscribe,x,subscribe_to})
        
        #ZIPF: Randomly start tweeting/retweeting/subscribe/querying activities acc to zipf rank

        acts = cond do
            x <= (clients*0.01) ->
                acts * 100
                
            x <= (clients*0.1) ->
                acts * 10
            
            x <= (clients*0.7) ->
                acts * 5

            true ->
                acts

        end

        # if (x < (clients*0.1)) do
        #     acts = acts * 10
        # end
        # if (x < (clients*.01) do
        #     acts = acts * 100
        # end

        # if 

        acts = acts * length(subscribe_to)
        
        GenServer.cast(self,{:pick_random,1})
        {:noreply,{x,acts,servernode,clients}}
    end

    def handle_cast({:pick_random,current_state},{x,acts,servernode,clients}) do
        if(current_state < acts) do
            choice = rem(round(:rand.uniform()*100000),5)
            case choice do
                1 ->   
                    #subscribe(x,servernode,clients)
                    tweet(x,servernode)  

                2 -> 
                    tweet(x,servernode)

                3 ->
                    queryhashtags(x,servernode)

                4 ->
                    querymentions(x,clients,servernode)

                _ ->
                    #querytweets(x)


            end
            GenServer.cast(self(),{:pick_random,current_state + 1})
        else
            GenServer.cast(:orc, {:acts_completed})
        end
        {:noreply,{x,acts,servernode,clients}}  
    end
    def handle_cast({:deactivate},{x,acts,servernode,clients})do
        #stop all activities, play dead
        #inform server
        {:noreply,{x,acts,servernode,clients}}
    end
    def handle_cast({:incoming_tweet,source,msg},{x,acts,servernode,clients})do
        IO.puts "user#{x} received a tweet from user#{source}:: #{msg}"
        {:noreply,{x,acts,servernode,clients}}
    end

    def handle_cast({:query_result,result},{x,acts,servernode,clients})do
        IO.puts "user #{x} received result of query:: #{result}"
        {:noreply,{x,acts,servernode,clients}}
    end

    def tweet(x,servernode) do
        #Generate a message
        msg = "160 random characters"
        GenServer.cast({:server,servernode},{:tweet,x,msg})
    end
    def subscribe(x,servernode,clients) do
        #Pick random user
        follow = :rand.uniform(clients)
        if follow != x do
            GenServer.cast({:server,servernode},{:subscribe,x,[follow]})
        end
    end
    def queryhashtags(x,servernode) do
        #Pick a random hashtag
        hashtag = "#twitter"
        GenServer.cast({:server,servernode},{:hashtags,x,hashtag})
    end
    def querymentions(x,clients,servernode) do
        #Pick a random user
        mention = "@user"<>Integer.to_string(:rand.uniform(clients))
        GenServer.cast({:server,servernode},{:mentions,x,mention})
    end
    
end