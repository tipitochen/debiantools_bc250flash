# debiantools_bc250flash
en este repositorio nos encontamos con los archivos para flashear la bios de la placa de mineria asrock bc 250 , tambien hay un script que nos facilita el proceso de instalacion de herramientas de debian 

Agradecimiento a estos dos proyectos:

#https://github.com/kenavru/BC-250
#https://gitlab.com/TuxThePenguin0/bc250-bios/

Que hicieron posible poder actualizar la bios de la placa desde una unidad USB

# Debian Tool Nikita Script (actualizador de Drivers mesa para bc250)
⚙️ [Script Debian Tool Nikita](Debian%20tool%20Nikita.sh)


# Parche bc250 (sugerencias comunidad [ git-](https://github.com/mothenjoyer69/bc250-documentation))
⚙️ [Script Parche bc250](Parche%bc%250.sh)

 este parche aplica lo sugerido por la comunidad:
 -agrega RADV_DEBUG=nocompute en /etc/environment para resolver problemas de vulkan.
- Agrega ttm.pages_limit=3959290 y ttm.page_pool_size=3959290 como una opcion del kernel para tener accesio a mas de 8gb de memoria compartida
- Carga los drives  the nct6683 drive para activar los sensores en el bash del usuario 
 
# Bios Flash BC-250

Guía para actualizar la BIOS de la placa BC-250.

📄 [Ver pasos completos en PDF](Actualizar%20Bios%20BC%20250/Pasos%20a%20seguir%20Flash%20Bc250.pdf)
## 📂 Archivos relacionados
- [Carpeta BIOS EFI](Actualizar%20Bios%20BC%20250/BIOS%20EFI)
