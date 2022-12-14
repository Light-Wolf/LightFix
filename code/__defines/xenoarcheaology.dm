#define ARCHAEO_BOWL 1
#define ARCHAEO_URN 2
#define ARCHAEO_CUTLERY 3
#define ARCHAEO_STATUETTE 4
#define ARCHAEO_INSTRUMENT 5
#define ARCHAEO_KNIFE 6
#define ARCHAEO_COIN 7
#define ARCHAEO_HANDCUFFS 8
#define ARCHAEO_BEARTRAP 9
#define ARCHAEO_LIGHTER 10
#define ARCHAEO_BOX 11
#define ARCHAEO_GASTANK 12
#define ARCHAEO_TOOL 13
#define ARCHAEO_METAL 14
#define ARCHAEO_PEN 15
#define ARCHAEO_CRYSTAL 16
#define ARCHAEO_CULTBLADE 17
#define ARCHAEO_TELEBEACON 18
#define ARCHAEO_CLAYMORE 19
#define ARCHAEO_CULTROBES 20
#define ARCHAEO_SOULSTONE 21
#define ARCHAEO_SHARD 22
#define ARCHAEO_RODS 23
#define ARCHAEO_STOCKPARTS 24
#define ARCHAEO_KATANA 25
#define ARCHAEO_LASER 26
#define ARCHAEO_GUN 27
#define ARCHAEO_UNKNOWN 28
#define ARCHAEO_FOSSIL 29
#define ARCHAEO_SHELL 30
#define ARCHAEO_PLANT 31
#define ARCHAEO_REMAINS_HUMANOID 32
#define ARCHAEO_REMAINS_ROBOT 33
#define ARCHAEO_REMAINS_XENO 34
#define ARCHAEO_GASMASK 35
#define MAX_ARCHAEO 35

#define DIGSITE_GARDEN 1
#define DIGSITE_ANIMAL 2
#define DIGSITE_HOUSE 3
#define DIGSITE_TECHNICAL 4
#define DIGSITE_TEMPLE 5
#define DIGSITE_WAR 6


#define EFFECT_TOUCH   (1<<0)
#define EFFECT_AURA    (1<<1)
#define EFFECT_PULSE   (1<<2)

#define EFFECTS_LIST \
list(\
EFFECT_TOUCH,\
EFFECT_AURA,\
EFFECT_PULSE,\
)


#define TRIGGER_TOUCH       (1<<0)
#define TRIGGER_WATER       (1<<1)
#define TRIGGER_ACID        (1<<2)
#define TRIGGER_VOLATILE    (1<<3)
#define TRIGGER_TOXIN       (1<<4)
#define TRIGGER_FORCE       (1<<5)
#define TRIGGER_ENERGY      (1<<6)
#define TRIGGER_HEAT        (1<<7)
#define TRIGGER_COLD        (1<<8)
#define TRIGGER_PLASMA      (1<<9)
#define TRIGGER_OXY         (1<<10)
#define TRIGGER_CO2         (1<<11)
#define TRIGGER_NITRO       (1<<12)
#define TRIGGER_DARK        (1<<13)
#define TRIGGER_LIGHT       (1<<14)

#define TRIGGERS_ENVIROMENT \
(\
 TRIGGER_HEAT | TRIGGER_COLD | TRIGGER_PLASMA |\
 TRIGGER_OXY  | TRIGGER_CO2  | TRIGGER_NITRO  |\
 TRIGGER_DARK | TRIGGER_LIGHT\
)

#define TRIGGERS_LIST \
list(\
TRIGGER_TOUCH,\
TRIGGER_WATER,\
TRIGGER_ACID,\
TRIGGER_VOLATILE,\
TRIGGER_TOXIN,\
TRIGGER_FORCE,\
TRIGGER_ENERGY,\
TRIGGER_HEAT,\
TRIGGER_COLD,\
TRIGGER_PLASMA,\
TRIGGER_OXY,\
TRIGGER_CO2,\
TRIGGER_NITRO,\
TRIGGER_DARK,\
TRIGGER_LIGHT\
)




#define EFFECT_UNKNOWN 0
#define EFFECT_ENERGY 1
#define EFFECT_PSIONIC 2
#define EFFECT_ELECTRO 3
#define EFFECT_PARTICLE 4
#define EFFECT_ORGANIC 5
#define EFFECT_BLUESPACE 6
#define EFFECT_SYNTH 7
#define EFFECT_TRANSFORM 8
