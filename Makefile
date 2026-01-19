# Build + switch
make switch

# Apenas build
make build

# Alternar containers
make containers-docker
make containers-podman

# Rollback / GC
make rollback
make gc-soft
make gc-hard

# Checagem rápida
make doctor
