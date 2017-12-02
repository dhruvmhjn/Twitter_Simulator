defmodule Client do
    use GenServer
    def start_link(x,clients,servernode,acts) do
        #input_srt = Integer.to_string(x)
        GenServer.start_link(__MODULE__, {x,acts,servernode,clients}, name: String.to_atom("user#{x}"))    
    end

    def init({x,acts,servernode,clients}) do        
       # Register self
       {:ok, {x,acts,servernode,clients,[]}}
    end

    def handle_cast({:register},{x,acts,servernode,clients,_})do
        tweets_pool = ["160 characters from user #{x}.","COP5615 is a good course.","#{x}This is a sample tweet.","Random tweet from user.","One more random tweet.", "And one more."]
        #ZIPF: Randomly start tweeting/retweeting/subscribe/querying activities acc to zipf rank
        acts = cond do
             x <= (clients*0.01) ->
                 acts * 20
                 
             x <= (clients*0.1) ->
                 acts * 10
             
             x <= (clients*0.6) ->
                 acts * 2
 
             true ->
                 acts
         end
        GenServer.cast({:server,servernode},{:registeruser,x})
        
        {:noreply,{x,acts,servernode,clients,tweets_pool}}
    end
    def handle_cast({:activate, subscribe_to},{x,acts,servernode,clients,tweets_pool})do
        #Subcribe to users
        #IO.puts "Client #{x} asked to activated, sub list = #{subscribe_to}"
        GenServer.cast({:server,servernode},{:subscribe,x,subscribe_to})
        #START TWEETING
        GenServer.cast(self(),{:pick_random,1})
        {:noreply,{x,acts,servernode,clients,tweets_pool}}
    end

    def handle_cast({:pick_random,current_state},{x,acts,servernode,clients,tweets_pool}) do
        if(current_state < acts) do
            choice = rem(:rand.uniform(999999),14)
            case choice do
                1 ->   
                    #subscribe(x,servernode,clients)
                    tweet_hash(x,servernode,tweets_pool,clients)  

                2 -> 
                    tweet_mention(x,servernode,tweets_pool,clients)

                3 ->
                    queryhashtags(x,servernode)

                4 ->
                    query_self_mentions(x,servernode)

                5 ->
                    discon(x,servernode)

                _ ->
                    tweet(x,servernode,tweets_pool)
                    #querytweets(x)

            end
            #Process.sleep (:rand.uniform(100))
            #IO.puts "client #{x} act #{acts}"
            GenServer.cast(self(),{:pick_random,current_state + 1})
        else
            IO.puts "User #{x} has finised generating at least #{acts} activities (Tweets/Queries)."
            GenServer.cast(:orc, {:acts_completed})
        end
        {:noreply,{x,acts,servernode,clients,tweets_pool}}  
    end
    # def handle_cast({:disconnect,time},{x,acts,servernode,clients,tweets_pool})do
    #     #stop all activities, play dead
    #     #inform server
    #     GenServer.cast({:server,servernode},{:disconnection,x})
    #     Process.sleep(time)
    #     GenServer.cast({:server,servernode},{:reconnection,x})
    #     {:noreply,{x,acts,servernode,clients,tweets_pool}}
    # end
    def handle_cast({:incoming_tweet,source,msg},{x,acts,servernode,clients,tweets_pool})do
        #IO.puts "user#{x} received a tweet from user#{source}:: #{msg}"
        if (:rand.uniform(999) == 99) do
            rt_msg = if (Regex.match?(~r/^RT, Source:/ , msg)) do
                msg
            else
                "RT, Source: #{source} Tweet: " <> msg
            end
            #IO.puts "Retweeting: "<>rt_msg
            GenServer.cast({:server,servernode},{:tweet,x,rt_msg})
        end
        {:noreply,{x,acts,servernode,clients,tweets_pool}}
    end

    def handle_cast({:query_result,_},{x,acts,servernode,clients,tweets_pool})do
        #IO.puts "user#{x} received result of query::"
        #IO.inspect result
        {:noreply,{x,acts,servernode,clients,tweets_pool}}
    end

    def tweet(x,servernode,tweets_pool) do
        #Generate a message
        msg = Enum.random(tweets_pool)
        GenServer.cast({:server,servernode},{:tweet,x,msg})
    end

    def tweet_hash(x,servernode,tweets_pool,_) do
        #Generate a message
        msg = Enum.random(tweets_pool) <> " #hashtag" <>Integer.to_string(:rand.uniform(999))
        GenServer.cast({:server,servernode},{:tweet,x,msg})
    end

    def tweet_mention(x,servernode,tweets_pool,clients) do
        msg = Enum.random(tweets_pool) <> " @user"<>Integer.to_string(:rand.uniform(clients))
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
        hashtag = "#hashtag" <>Integer.to_string(:rand.uniform(999))
        GenServer.cast({:server,servernode},{:hashtags,x,hashtag})
    end
    def query_self_mentions(x,servernode) do
        mention = "@user"<>Integer.to_string(x)
        GenServer.cast({:server,servernode},{:mentions,x,mention})
    end

    def discon(x,servernode)do
        #stop all activities, play dead
        #inform server
        time = :rand.uniform(5)*10
        GenServer.cast({:server,servernode},{:disconnection,x})
        Process.sleep(time)
        GenServer.cast({:server,servernode},{:reconnection,x})
    end
    
end