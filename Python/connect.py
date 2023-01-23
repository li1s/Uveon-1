import ovirtsdk4 as sdk
import ovirtsdk4.types as types
import math

# Create a connection to the server:
connection = sdk.Connection(
    url='https://tsto06-ovm.sl.loc/ovirt-engine/api',
    username='admin@internal',
    password='657frodo',
    ca_file='/home/l1is/pki-resource'
)

vms_service = connection.system_service().vms_service()

virtual_machines = vms_service.list()

if len(virtual_machines) > 0:

    print("%-30s  %s" % ("Name", "Disk Size"))
    print("==================================================")

    for virtual_machine in virtual_machines:
        vm_service = vms_service.vm_service(virtual_machine.id)
        disk_attachments = vm_service.disk_attachments_service().list()
        disk_size = 0
        for disk_attachment in disk_attachments:
            disk = connection.follow_link(disk_attachment.disk)
            # Килобайты в Гигабайты
            disk_size += (((disk.provisioned_size)/ 1048576)/ 1024)
            #disk_size += disk.provisioned_size

            print("%-30s: %d" % (virtual_machine.name, disk_size)+" Gb")

# Close the connection to the server:
connection.close()