defmodule Server do
    use GenServer
    def start_link(n,_,clientnode) do
        GenServer.start_link(__MODULE__, {n}, name: String.to_atom("server"))    
    end
    def init({n}) do        
        # state: 
        # ets tables
        :ets.new(:tab_user, [:set, :protected, :named_table])
         {:ok, {n}}
     end
     def handle_call({:registeruser,x},_,{n}) do
        #update table (add a new user x)
        IO.puts("Registering user #{x}")

        :ets.insert_new(:tab_user, {x, [], [], "alive"})
        #res = :ets.lookup(:tab_user, "qwerty")
        #IO.inspect res
        [_,_,_,_,_,_,_,{:size, recsize},_,_,_,_,_] = :ets.info(:tab_user)
        IO.inspect recsize
        {:reply,"ok",{n}}
     end
     def handle_cast({:subscribe,x,subscribe_to},{n})do
        #update table (add subscribe to for user x)
        [{_,old_list,_,_}] = :ets.lookup(:tab_user, x)
        subscribe_to = subscribe_to -- [x]
        new_list = Enum.uniq(old_list++subscribe_to)
        :ets.update_element(:tab_user, x, {2, new_list})
        #update table (add x to followers list)
        res = Enum.map(subscribe_to, fn(y)->:ets.update_element(:tab_user, y, {3, [x]++List.flatten(:ets.match(:tab_user, {y,:"_",:"$1",:"_"}))})end)
        IO.inspect :ets.select(:tab_user, [{{:"$1", :"$2", :"$3",:"$4"}, [], [:"$_"]}])
        {:noreply,{n}}
     end
     def handle_cast({:tweet,x,msg},{n})do
        #update table (add msg to tweet list of x)
        #cast message to all subscribers of x if ALIVE
        {:noreply,{n}}
     end
end