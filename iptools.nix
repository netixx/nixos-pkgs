{ config, pkgs, ... }:
with pkgs.lib;
rec {
    # netInfo = lan:
    #     {
    #         _lan = splitString "/" lan;
    #         address = _lan[0];
    #         prefixLength = _lan[1];
    #         netmask = ((1<<prefixLength)-1);
    #         network = address & ~netmask;
    #     };

    # toNetwork = lan: (netInfo lan).network;
    # toNetmask = lan: (netInfo lan).netmask;
    makeAddress = lanConfig: attribute: suffix:
        if attribute == null then "${config.settopbox.prefix}.${toString lanConfig.lanId}.${toString suffix}" else attribute;

    makeGateway = lanConfig: (makeAddress lanConfig lanConfig.network 254);
    makeNetwork = lanConfig: (makeAddress lanConfig lanConfig.network 0);

    makeCidr = lanConfig: "${makeGateway lanConfig}/${toString lanConfig.prefixLength}";

    makeRange = lanConfig:
        if lanConfig.services.dhcp.range != null then lanConfig.services.dhcp.range else (makeAddress lanConfig null 1) + " " + (makeAddress lanConfig null 253);

    makeVlan = lanConfig: if lanConfig.vlan == null then lanConfig.lanId else lanConfig.vlan;

}
