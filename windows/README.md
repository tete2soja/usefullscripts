# Windows

Windows propose un outil qui est PowerShell. Il permet de faire un ensemble d'opérations plus ou moins complexes sur un ordinateur.

Les scripts suivants utilisent tous cet outil ce qui permet de les rendre portable sur l'ensemble des postes Windows possédant PowerShell.

## infoPC.ps1

Permet de récupérer un ensemble d'informations sur le PC local ou distant via WMI/CIM. Le résultat est mis en forme et stocké sous forme d'un fichier HTML.

Une partie des résultats est également stockée dans un fichier CSV afin d'être réutilisé dans le script ```stats_pc.ps1```.

## install_base.ps1

## optimize.ps1

## stats_pc.ps1

Il permet l'exploitation des résultats fournis précédemment via le script ```infoPC.ps1```. Il renvoie l'ensemble sous forme de graphique de type camembert avec un tableau ou l'ensemble des valeurs y est reporté. Cela permet de faire un tri sur ces valeurs en les rangeant par ordre croissant ou décroissant.

![](https://lut.im/Hu554aDFY5/Nn773p4dJx5zeyod)