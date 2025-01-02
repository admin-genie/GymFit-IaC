#!/bin/bash
# Vagrantfile에서 호스트 이름들을 추출하여 배열에 저장
hostnames=($(awk '/config.vm.define/ {print $4}' Vagrantfile))

# 인벤토리를 저장할 파일 생성
inventory_file="inventory.txt"

# 인벤토리 파일 초기화
>$inventory_file

# 각 호스트 이름에 대해 반복하여 작업 수행
for hostname in "${hostnames[@]}"; do
    echo "Status for host: $hostname"
    vagrant status $hostname # 호스트 상태 출력

    # 호스트의 IP 주소 가져오기
    ip_address=$(vagrant ssh-config $hostname | awk '/HostName/ {print $2}')

    # 호스트의 포트 정보 가져오기
    port_info=$(vagrant port $hostname)

    # 포트 정보에서 호스트 포트 추출
    host_port=$(echo "$port_info" | awk '/22 \(guest\) =>/ {print $3}')

    # 변수에 저장
    inventory_entry="$hostname ansible_host=$ip_address ansible_port=$host_port"

    # 인벤토리 파일에 추가
    echo $inventory_entry >>$inventory_file

    # 인벤토리에 추가된 항목 출력
    echo "Inventory entry for host $hostname:"
    echo $inventory_entry
done

# info.data 파일 초기화
>info.data

# 각 호스트 이름에 대해 반복하여 작업 수행
for hostname in "${hostnames[@]}"; do
    echo "Status for host: $hostname"
    vagrant status $hostname # 호스트 상태 출력

    # 호스트의 IP 주소 가져오기
    ip_address=$(vagrant ssh-config $hostname | awk '/HostName/ {print $2}')

    # 호스트의 포트 정보 가져오기
    port_info=$(vagrant port $hostname)

    # 포트 정보에서 호스트 포트 추출
    host_port=$(echo "$port_info" | awk '/22 \(guest\) =>/ {print $3}')

    # 호스트의 IP 주소와 SSH 포트를 info.data 파일에 추가
    echo "Host $hostname IP=$ip_address SSH_PORT=$host_port" >>info.data
done
