# OCcraft
This program was made for [OpenComputers](https://github.com/MightyPirates/OpenComputers).
Its purpose is to craft items, it does so by checking the recipes from a file,
under */home/recipes*, and then just filling in items. Usage:
> craft.lua "Central Processing Unit (CPU) (Tier 1)"

# recipes file format example
> {Cable={
>   items=8,
>   nil, "Iron_Nugget", nil,
>   "Iron_Nugget", "Redstone", "Iron_Nugget"
>   nil, "Iron_Nugget"
>   },
> }