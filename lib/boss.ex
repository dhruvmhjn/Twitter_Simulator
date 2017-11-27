defmodule Boss do
    def main(args) do 
        parse_args(args)
    end
    defp parse_args(args) do
        cmdarg = OptionParser.parse(args)
        {[],[argstr],[]} = cmdarg
        #{[],[numClients,timePeriod,role],[]} = cmdarg

        #sregex = ~r/^server/
        cregex = ~r/[\d]*\s[\d]*\s\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
        {:ok,[{ip,_,_}|tail]}=:inet.getif()
        [{ip2,_,_}|_]=tail
        ipofsnode =to_string(:inet.ntoa(ip2))

        if Regex.match?(cregex,argstr) do
            #Client Simulator
            
            [numClients,timePeriod,serverip]=String.split(argstr," ")
            numClientsInt = String.to_integer(numClients)
            timePeriodInt = String.to_integer(timePeriod)
            snode=String.to_atom("clientnode@"<>ipofsnode)
            Node.start snode
            Node.set_cookie :dmahajan
            :global.register_name(:client_boss, self())
            servernode = String.to_atom("servernode@"<>serverip)
            connect_result = Node.connect(servernode)
            :global.sync()
            if (connect_result == true) do
                IO.puts "Successfully connected to server at #{serverip}."
                IO.puts "Starting twitter simulation with #{numClients} users on node #{snode}"
                IO.puts "The Activity level of each user is a multiple (ZIPF) of the Minimum activities entered."
                ClientSupervisor.start_link([numClientsInt,timePeriodInt,servernode]) 
            else
                IO.puts "Can't connect to server at #{serverip} , try again."
            end
            GenServer.call({:server,servernode},{:simulator_add,snode})
        else
            #Server Twitter Engine
            snode=String.to_atom("servernode@"<>ipofsnode)
            Node.start snode
            Node.set_cookie :dmahajan
            :global.register_name(:server_boss, self())
            IO.puts "Starting twitter engine on node #{snode}"
            ApplicationSupervisor.start_link([String.to_atom("nonames@"<>"noonodess")]) 
        end

        # numClientsInt = String.to_integer(numClients)
        # timePeriodInt = String.to_integer(timePeriod)
        # {:ok,[{ip,_,_}|tail]}=:inet.getif()
        # [{ip2,_,_}|_]=tail
        # ipofsnode =to_string(:inet.ntoa(ip2))
        # if role == "server" do
        #     #ipofsnode =to_string(:inet.ntoa(ip2))
        #     snode=String.to_atom("servernode@"<>ipofsnode)
        #     Node.start snode
        #     Node.set_cookie :dmahajan
        #     :global.register_name(:server_boss, self())
        #     ApplicationSupervisor.start_link([numClientsInt,timePeriodInt,String.to_atom("clientnode@"<>"192.168.0.12")]) 
        # else
        #     snode=String.to_atom("clientnode@"<>ipofsnode)
        #     Node.start snode
        #     Node.set_cookie :dmahajan
        #     :global.register_name(:client_boss, self())
        #     servernode = String.to_atom("servernode@"<>role)
        #     IO.inspect servernode
        #     abc = Node.connect(servernode)
        #     IO.inspect Node.list
        #     :global.sync()
        #     ClientSupervisor.start_link([numClientsInt,timePeriodInt,servernode]) 
        # end
        boss_receiver()
    end         
    def boss_receiver() do
        receive do
             {:all_requests_served} ->
                 IO.puts "All requests served, simulation and engine terminating"
                 :init.stop                
         end
        boss_receiver()
       
    end
end