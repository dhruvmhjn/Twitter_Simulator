defmodule Boss do
    def main(args) do 
        parse_args(args)
    end
    defp parse_args(args) do
        cmdarg = OptionParser.parse(args)

        {[],argstr,[]} = cmdarg
        #{[],[numClients,timePeriod,role],[]} = cmdarg

        sregex = ~r/^server/

        #ipregex = ~r/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
        {:ok,[{ip,_,_}|tail]}=:inet.getif()
        [{ip2,_,_}|_]=tail
        ipofsnode =to_string(:inet.ntoa(ip2))

        if Regex.match?(sregex,Enum.at(argstr,0)) do
            #Server Twitter Engine
            snode=String.to_atom("servernode@"<>ipofsnode)
            Node.start snode
            Node.set_cookie :dmahajan
            :global.register_name(:server_boss, self())
            IO.puts "Starting twitter engine on node #{snode}"
            ApplicationSupervisor.start_link([String.to_atom("nonames@"<>"noonodess")]) 
        else
            #Client Simulators
            [numClients,minActs,subPercent,serverip]=argstr
            numClientsInt = String.to_integer(numClients)
            minActsInt = String.to_integer(minActs)
            subPercentInt = String.to_float(subPercent)
            snode=String.to_atom("clientnode@"<>ipofsnode)
            Node.start snode
            Node.set_cookie :dmahajan
            :global.register_name(:client_boss, self())
            servernode = String.to_atom("servernode@"<>serverip)
            connect_result = Node.connect(servernode)
            :global.sync()
            if (connect_result == true) do
                GenServer.call({:server,servernode},{:simulator_add,snode})
                IO.puts "Successfully connected to server at #{serverip}."
                IO.puts "Starting twitter simulation with #{numClients} users on node #{snode}"
                IO.puts "The Activity level of each user is a multiple (ZIPF) of the Minimum activities entered."
                ClientSupervisor.start_link([numClientsInt,minActsInt,subPercentInt,servernode]) 
            else
                IO.puts "Can't connect to server at #{serverip} , try again."
            end
        end
        boss_receiver()
    end         
    def boss_receiver() do
        receive do
            {:all_requests_served_s} ->
                IO.puts "All requests served, engine terminating. Check simulator console for summary stats."
                :init.stop
            {:all_requests_served_c,time_taken,clients,acts,subPercent} ->
                time_taken = time_taken/1000
                IO.puts "All requests served, simulation terminating."
                IO.puts "Summary Statics"
                IO.puts "Total time (Seconds): #{time_taken}"
                IO.puts "Number of requests generated and served."
                IO.puts "   Minimum activities : #{acts}"
                IO.puts "   Top 1% of the clients do at least 100 times the minumum activities."
                IO.puts "   Next 9% of the clients do at least 10 times the minumum activities."
                IO.puts "   Next 50% of the clients do at least 2 times the minumum activities."
                IO.puts "   Rest 40% of the clients do at least the minumum activities."
                IO.puts "Total, approx = #{acts*100} * #{clients*0.01} + #{acts*10} * #{clients*0.09} + #{acts*2} * #{clients*0.5} + #{acts} * #{clients*0.4}"
                tot = (acts*100 * clients*0.01) + (acts* 10 * clients*0.09) + (acts*2 * clients*0.5) + (acts * clients*0.4)
                IO.puts "Approx total: #{round(tot)}"
                #time_taken = time_taken/1000
                IO.puts "Approx. Requests per second: #{tot/time_taken}"
                :init.stop                 
         end
        boss_receiver()
       
    end
end