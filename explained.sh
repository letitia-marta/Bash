#!usr/bin/bash

pid_list=$(ps aux | awk 'NR>1 {print $2}')
# ps aux afiseaza sub forma de tabel procesele si datele despre ele: user, pid, CPU, memorie etc
# NR>1 elimina capul tabelului
# $2 - coloana a 2-a, ce contine PID

for pid in $pid_list; do
        cpu=$(pidstat -p "$pid" | awk 'NR==4 {print $8}')
        # pidstat ofera sub forma de tabel date despre procese
        # linia 4 e linia cu procesul (inainte e o linie cu informatii, o linie goala si capul de tabel)
        # pe coloana 8 sunt informatiile despre CPU

        memory=$(ps -p "$pid" -o %mem | awk 'NR==2 {print $1}')
        # ps -p "$pid" extrage din tabel datele despre procesul cu PID=pid
        # %mem extrage din linie doar memoria (din coloana mem)
        # NR==2 pentru a selecta linia cu procesul (prima linie e capul de tabel)
        # se afiseaza prima coloana a selectiei

        io=$(pidstat -p "$pid" | awk 'NR==4 {print $6}')
        # pidstat ofera sub forma de tabel date despre procese
        # in mod normal pe coloana 6 sunt informatiile despre I/O

        if [[ $cpu =~ ^[0-9]*[.]?[0-9]+$ ]]; then
        # formatare: verificam ca CPU e un numar valid
                if [[ $memory =~ ^[0-9]*[.]?[0-9]+$ ]]; then
                # formatare: verificam ca memory e un numar valid
                        if [[ $io =~ ^[0-9]+$ ]]; then
                                if [[ $io == "0" && $cpu == "0.0" ]]; then
                                        bound="Unable to determine whether CPU or I/O bound"
                                elif [[ $io == "0" ]]; then
                                        bound="CPU bound"
                                        # cazul in care io = 0, pentru a nu imparti la 0
                                else
                                        bound=$(echo "$cpu / $io" | awk '{if ($1 > 1) print "CPU bound"; else print "I/O bound"}')
                                        # calculam raportul cpu/io pentru a apecia tipul procesului
                                        # daca fractia a supraunitara, e CPU bound
                                        # daca fractia e subunitara, e I/O bound
                                fi
                                echo "PID: $pid - CPU utilization: $cpu% ; Memory utilization: $memory% ; I/O utilization: $io bytes ; $bound"
                        else
                                echo "PID: $pid - CPU utilization: $cpu% ; Memory utilization: $memory% ; Unable to retrieve I/O utilization"
                        fi
                else
                        if [[ $io =~ ^[0-9]+$ ]]; then
                                if [[ $io == "0" && $cpu == "0.0" ]]; then
                                        bound="Unable to determine whether CPU or I/O bound"
                                elif [[ $io == "0" ]]; then
                                        bound="CPU bound"
                                else
                                        bound=$(echo "$cpu / $io" | awk '{if ($1 > 1) print "CPU bound"; else print "I/O bound"}')
                                fi
                                echo "PID: $pid - CPU utilization: $cpu% ; Unable to retrieve memory utilization ; I/O utilization: $io bytes ; $bound"
                        else
                                echo "PID: $pid - CPU utilization: $cpu% ; Unable to retrieve memory utilization ; Unable to retrieve I/O utilization"
                        fi
                fi
        else
                if [[ $memory =~ ^[0-9]*[.]?[0-9]+$ ]]; then
                        if [[ $io =~ ^[0-9]+$ ]]; then
                                echo "PID: $pid - Unable to retrieve CPU utilization ; Memory utilization: $memory% ; I/O utilization: $io bytes"
                        else
                                echo "PID: $pid - Unable to retrieve CPU utilization ; Memory utilization: $memory% ; Unable to retrieve I/O utilization"
                        fi
                else
                        if [[ $io =~ ^[0-9]+$ ]]; then
                                echo "PID: $pid - Unable to retrieve CPU utilization ; Unable to retrieve memory utilization ; I/O utilization: $io bytes"
                        else
                                echo "PID: $pid - Unable to retrieve CPU utilization ; Unable to retrieve memory utilization ; Unable to retrieve I/O utilization"
                        fi
                fi
        fi
done
