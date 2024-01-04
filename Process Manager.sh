#!usr/bin/bash

pid_list=$(ps aux | awk 'NR>1 {print $2}')

for pid in $pid_list; do
        cpu=$(ps -p "$pid" -o %cpu | awk 'NR==2 {gsub(/%/, ""); print $1}')
        memory=$(ps -p "$pid" -o %mem | awk 'NR==2 {print $1}')
        io=$(ps -p $pid -o nvcsw,nivcsw --no-headers | awk '{print $1 + $2}')

        if [[ $cpu =~ ^[0-9]*[.]?[0-9]+$ ]]; then
                if [[ $memory =~ ^[0-9]*[.]?[0-9]+$ ]]; then
                        if [[ $io =~ ^[0-9]+$ ]]; then
                                if [[ $io == "0" && $cpu == "0.0" ]]; then
                                        bound="Unable to determine whether CPU or I/O bound"
                                elif [[ $io == "0" ]]; then
                                        bound="CPU bound"
                                else
                                        bound=$(echo "$cpu / $io" | awk '{if ($1 > 1) print "CPU bound"; else print "I/O bound"}')
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
