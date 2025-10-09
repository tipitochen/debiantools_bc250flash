#!/bin/bash

while true; do
    clear
    echo "============================================="
    echo "      BC250 Setup – Parche de Kernel"
    echo "============================================="
    echo
    echo "Selecciona una opción:"
    echo "1) Aplicar parche de kernel (BC‑250)"
    echo "2) Activar variable RADV_DEBUG"
    echo "3) (Opcional) Parche de sensores nct6683"
    echo "4) Chequear estado"
    echo "5) Salir"
    echo
    read -p "Opción: " opt

    case $opt in
    1)
        echo
        echo "==> Aplicando parche de Kernel (BC‑250)…"
        GRUB_FILE="/etc/default/grub"
        if [ -f "$GRUB_FILE" ]; then
            sudo sed -i 's/nomodeset//g' $GRUB_FILE
            if grep -q "GRUB_CMDLINE_LINUX_DEFAULT" $GRUB_FILE; then
                sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ amdgpu.sg_display=0 ttm.pages_limit=3959290 ttm.page_pool_size=3959290"/' $GRUB_FILE
            fi
            sudo update-grub
            sudo update-initramfs -u
            echo "✅ Parche del kernel aplicado. Reinicia el sistema para activar los cambios."
        else
            echo "⚠️  No se encontró /etc/default/grub. Verifica tu instalación del gestor de arranque."
        fi
        ;;
    2)
        echo
        echo "==> Activando RADV_DEBUG=nocompute"
        # Colocar la variable globalmente para todos los entornos gráficos
        sudo bash -c 'echo "RADV_DEBUG=nocompute" >> /etc/environment'
        echo "✅ Variable RADV_DEBUG establecida en /etc/environment"
        ;;
    3)
        echo
        echo "==> (Opcional) Activar sensor nct6683"
        sudo modprobe nct6683 force=1 2>/dev/null || echo "⚠️ No se pudo cargar nct6683 (o módulo no existe)."
        sudo tee /etc/modules-load.d/nct6683.conf <<< "nct6683" >/dev/null
        sudo tee /etc/modprobe.d/nct6683.conf <<< "options nct6683 force=1" >/dev/null
        sudo update-initramfs -u
        echo "✅ Intentado parche de sensores."
        ;;
    4)
        echo
        echo "==> Estado actual del sistema"
        echo "---------------------------------------------"
        if lsmod | grep -q "nct6683"; then
            echo "✅ Sensores: módulo nct6683 cargado"
        else
            echo "⚠️  Sensores: nct6683 no cargado"
        fi

        CMDLINE=$(cat /proc/cmdline)
        if echo "$CMDLINE" | grep -q "ttm.pages_limit=3959290" && echo "$CMDLINE" | grep -q "amdgpu.sg_display=0"; then
            echo "✅ Kernel options: OK"
        else
            echo "⚠️  Kernel options faltantes para BC‑250"
        fi

        # Revisar variable RADV_DEBUG activa en entorno actual
        if [ "$RADV_DEBUG" = "nocompute" ]; then
            echo "✅ RADV_DEBUG activo en sesión"
        else
            echo "⚠️  RADV_DEBUG no activo (o no leído aún)."
        fi
        echo "---------------------------------------------"
        ;;
    5)
        echo "Saliendo."
        exit 0
        ;;
    *)
        echo "Opción inválida."
        ;;
    esac

    echo
    read -p "Presiona ENTER para continuar..."
done

