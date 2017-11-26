defmodule Server do
    use GenServer
    def start_link(n,_,clientnode) do
        GenServer.start_link(__MODULE__, {n,clientnode}, name: String.to_atom("server"))    
    end
    def init({n,clientnode}) do        
        # state: 
        # ets tables
        :ets.new(:tab_user, [:set, :protected, :named_table])
        :ets.new(:tab_tweet, [:set, :protected, :named_table])
        :ets.new(:tab_msgq, [:set, :protected, :named_table])
        :ets.new(:tab_hashtag, [:set, :protected, :named_table])
        :ets.new(:tab_mention, [:set, :protected, :named_table])
         {:ok, {n,clientnode}}
     end
     def handle_call({:registeruser,x},_,{n,clientnode}) do
        #update table (add a new user x)
        IO.puts("Registering user #{x}")

        :ets.insert_new(:tab_user, {x, [], [], "alive",0})
        #res = :ets.lookup(:tab_user, "qwerty")
        #IO.inspect res
        [_,_,_,_,_,_,_,{:size, recsize},_,_,_,_,_] = :ets.info(:tab_user)
        #IO.inspect recsize
        {:reply,"ok",{n,clientnode}}
     end
     def handle_cast({:subscribe,x,subscribe_to},{n,clientnode})do
        #update table (add subscribe to for user x)
        [{_,old_list,_,_,_}] = :ets.lookup(:tab_user, x)
        subscribe_to = Enum.uniq(subscribe_to) -- [x]
        IO.puts "user#{x} is now following #{subscribe_to}"
        new_list = Enum.uniq(old_list++subscribe_to)
        :ets.update_element(:tab_user, x, {2, new_list})
        #update table (add x to followers list)
        res = Enum.map(subscribe_to, fn(y)->:ets.update_element(:tab_user, y, {3, [x]++List.flatten(:ets.match(:tab_user, {y,:"_",:"$1",:"_"}))})end)
        #IO.inspect :ets.select(:tab_user, [{{:"$1", :"$2", :"$3",:"$4"}, [], [:"$_"]}])
        {:noreply,{n,clientnode}}
     end
     def handle_cast({:tweet,x,msg},{n,clientnode})do
        #update tweet counter
        [{_,_,followers_list,_,old_count}] = :ets.lookup(:tab_user, x)
        :ets.update_element(:tab_user, x, {5, old_count+1})
        #update tweet table (add msg to tweet list of x)
        tweetid = Integer.to_string(x)<>"T"<>Integer.to_string(old_count+1)
        :ets.insert_new(:tab_tweet, {tweetid,x,msg})
        #cast message to all subscribers of x if ALIVE
        Enum.map(followers_list,fn(y)-> Genserver.cast({String.to_atom("user"<>Integer.to_string(y)),clientnode},{:incoming_tweet,x,msg})end)

        {:noreply,{n,clientnode}}
     end
end