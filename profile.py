"""This topology has four hosts - three arranged like a home network with a gateway, and a fourth representing an external service. 

To use this topology, follow the instructions at [Basic home gateway services: DHCP, DNS, NAT](https://witestlab.poly.edu/blog/basic-home-gateway-services-dhcp-dns-nat/).

"""

# Import the Portal object.
import geni.portal as portal
# Import the ProtoGENI library.
import geni.rspec.pg as pg
# Import the Emulab specific extensions.
import geni.rspec.emulab as emulab

# Create a portal object,
pc = portal.Context()

# Create a Request object to start building the RSpec.
request = pc.makeRequestRSpec()

# Node gateway
node_gateway = request.XenVM('gateway')
node_gateway.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
node_gateway.Site("site1")

iface0 = node_gateway.addInterface('interface-1', pg.IPv4Address('192.168.100.1','255.255.255.0'))

# Node client-1
node_client_1 = request.XenVM('client-1')
node_client_1.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
node_client_1.startVNC()
node_client_1.routable_control_ip = True
node_client_1.Site("site1")

iface1 = node_client_1.addInterface('interface-2', pg.IPv4Address('0.0.0.0','255.255.255.0'))

# Node client-2
node_client_2 = request.XenVM('client-2')
node_client_2.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
node_client_2.Site("site1")

iface2 = node_client_2.addInterface('interface-0', pg.IPv4Address('0.0.0.0','255.255.255.0'))

# Node website
node_website = request.XenVM('website')
node_website.routable_control_ip = True
node_website.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
node_website.Site("site2")
# need two clusters - otherwise with NAT experiment it's not via default GW

# Link link-0
link_0 = request.Link('link-0')
link_0.addInterface(iface2)
link_0.addInterface(iface0)
link_0.addInterface(iface1)


# Print the generated rspec
pc.printRequestRSpec(request)

