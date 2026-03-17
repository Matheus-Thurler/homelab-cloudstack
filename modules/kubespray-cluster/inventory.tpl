[all]
%{ for i, node in controls ~}
${node.name} ansible_host=${public_ip} ansible_port=${ssh_base_port + i} ansible_user=ubuntu
%{ endfor ~}
%{ for i, node in workers ~}
${node.name} ansible_host=${public_ip} ansible_port=${ssh_base_port + control_count + i} ansible_user=ubuntu
%{ endfor ~}

[kube_control_plane]
%{ for node in controls ~}
${node.name}
%{ endfor ~}

[etcd]
%{ for node in controls ~}
${node.name}
%{ endfor ~}

[kube_node]
%{ for node in workers ~}
${node.name}
%{ endfor ~}

[k8s_cluster:children]
kube_control_plane
kube_node
