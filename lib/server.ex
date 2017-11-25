defmodule Server do
    use GenServer
    def start_link(n,_) do
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
        {:noreply,{n}}
     end
     def handle_cast({:tweet,x,msg},{n})do
        #update table (add msg to tweet list of x)
        #cast message to all subscribers of x
        {:noreply,{n}}
     end
end