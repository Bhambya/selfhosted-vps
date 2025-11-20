### Terraform Structure

```
terraform/
├── vps/                   # Oracle Cloud Infrastructure
│   ├── main.tf            # OCI networking and module orchestration
│   ├── gateway/           # Main gateway VPS module
│   └── little-gateway/    # Secondary/backup gateway module
└── homeserver/            # Proxmox home infrastructure  
    ├── main.tf            # VM definitions and cloud-init config
    └── ubuntu_vm/         # Reusable VM module for Proxmox
```

### Deployment Commands

**Deploy OCI VPS Infrastructure**:
```bash
cd terraform/vps
tofu init
tofu plan
tofu apply
```

**Deploy Home Server VMs**:
```bash
cd terraform/homeserver  
tofu init
tofu plan
tofu apply
```