nix develop path:.
mstart
mcreatedb meuapp
mseed meuapp
mconnect

# dentro do mongosh: use meuapp; db.users.find();

mstop
