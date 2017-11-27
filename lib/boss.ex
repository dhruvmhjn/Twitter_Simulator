defmodule Boss do
    def main(args) do 
        parse_args(args)
    end
    defp parse_args(args) do
        cmdarg = OptionParser.parse(args)
        {[],[numClients,timePeriod,role],[]} = cmdarg

        sregex = ~r/\d{1,2}$/
        cregex = ~r/\d\s\d\s\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/

        numClientsInt = String.to_integer(numClients)
        timePeriodInt = String.to_integer(timePeriod)
        {:ok,[{ip,_,_}|tail]}=:inet.getif()
        [{ip2,_,_}|_]=tail
        ipofsnode =to_string(:inet.ntoa(ip2))
        if role == "server" do
            #ipofsnode =to_string(:inet.ntoa(ip2))
            snode=String.to_atom("servernode@"<>ipofsnode)
            Node.start snode
            Node.set_cookie :dmahajan
            :global.register_name(:server_boss, self())
            ApplicationSupervisor.start_link([numClientsInt,timePeriodInt,String.to_atom("clientnode@"<>"192.168.0.12")]) 
        else
            snode=String.to_atom("clientnode@"<>ipofsnode)
            Node.start snode
            Node.set_cookie :dmahajan
            :global.register_name(:client_boss, self())
            servernode = String.to_atom("servernode@"<>role)
            IO.inspect servernode
            abc = Node.connect(servernode)
            IO.inspect Node.list
            :global.sync()
            ClientSupervisor.start_link([numClientsInt,timePeriodInt,servernode]) 
        end
        boss_receiver(numClientsInt,timePeriodInt)
    end         
    def boss_receiver(numClients,timePeriod) do
        receive do
             {:all_requests_served,b} ->
                 #avg = b/(numNodes*numRequests)
                 IO.puts "Total Hops: #{b}"
                #  IO.puts "Average Hops: #{avg}"
                 :init.stop                
         end
        boss_receiver(numClients,timePeriod)
       
    end
end