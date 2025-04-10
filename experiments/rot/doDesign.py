#!/usr/bin/env python3

import sys
import traceback
from   coriolis.Hurricane  import DbU, Breakpoint, PythonAttributes, Instance, Transformation
from   coriolis            import CRL, Cfg
from   coriolis.helpers    import loadUserSettings, setTraceLevel, trace, overlay, l, u, n
from   coriolis.helpers.io import ErrorMessage, WarningMessage, catch
from   coriolis            import plugins
from   coriolis.plugins.block.block          import Block
from   coriolis.plugins.block.configuration  import IoPin, GaugeConf
from   coriolis.plugins.block.spares         import Spares
from   pdks.ihpsg13g2_c4m.core2chip.sg13g2io import CoreToChip
from   coriolis.plugins.chip.configuration   import ChipConf
from   coriolis.plugins.chip.chip            import Chip
from   connectors_placement                 import *

af = CRL.AllianceFramework.get()


CoreName = 'rot'
scalar_a, scalar_b = 650*4, 100*4
connectors_margin = 6


def get_signals_hurricane(entity):
# from coriolis.designflow.technos import setupSky130_c4m
# from coriolis import CRL
# setupSky130_c4m( '../../..', '../../../pdkmaster/C4M.Sky130' )
# af = CRL.AllianceFramework.get()
 cell_blif  = CRL.Blif.load(f'{entity}.blif')
 #get supply pins not used in placement
 supply_pins = [j.getName() for j in cell_blif.getSupplyNets()]
 vectors = {}
 for i in cell_blif.getExternalNets():
     #vector_name
     a=i.getName()
     vector = a.split('(')[0]
     if vector in vectors:
      #vector size
      vectors[vector][1] += 1
      #first bit of vector, it is 0 in most cases
      vectors[vector][2]=min(vectors[vector][2],int(a.split(')')[0].split('(')[1]))
     else:
         supply = False
         for s in supply_pins:
             if vector == s:
                 supply = True
         if supply == False:
             if '(' in a:
              bit = int(a.split(')')[0].split('(')[1])
             else: 
              bit = 0   
             vectors[vector] = [vector,1,bit]
 signals_sorted={}
 #In order to have a dictionnary with a number as key
 #usefull for sorting signals in other functions
 for i, key in enumerate(vectors):
  signals_sorted[i] = vectors[key]
 return signals_sorted
combinational =0

def scriptMain ( **kw ):
    """The mandatory function to be called by Coriolis CGT/Unicorn."""
    global af,CoreName
    dico = get_signals_hurricane(CoreName)
    gaugeName = None
    with overlay.CfgCache(priority=Cfg.Parameter.Priority.UserFile) as cfg:
        cfg.misc.catchCore              = False
        cfg.misc.info                   = False
        cfg.misc.paranoid               = False
        cfg.misc.bug                    = False
        cfg.misc.logMode                = True
        cfg.misc.verboseLevel1          = True
        cfg.misc.verboseLevel2          = True
        cfg.misc.minTraceLevel          = 16000
        cfg.misc.maxTraceLevel          = 17000
        cfg.anabatic.routingGauge       = None   # Trigger disk loading.
        gaugeName = cfg.anabatic.routingGauge

    hpitch       = 0
    vpitch       = 0
    routingGauge = af.getRoutingGauge( gaugeName )
    for layerGauge in routingGauge.getLayerGauges():
        if layerGauge.getType() in [ CRL.RoutingLayerGauge.PinOnly
                                   , CRL.RoutingLayerGauge.Unusable
                                   , CRL.RoutingLayerGauge.BottomPowerSupply ]:
            continue
        if not hpitch and layerGauge.getDirection() == CRL.RoutingLayerGauge.Horizontal:
            hpitch = layerGauge.getPitch()
        if not vpitch and layerGauge.getDirection() == CRL.RoutingLayerGauge.Vertical:
            vpitch = layerGauge.getPitch()
    sliceHeight = af.getCellGauge().getSliceHeight()
    sliceStep   = af.getCellGauge().getSliceStep  ()
    print( '  o  Looked up gauge/pitch values.' )
    print( '     - hpitch: {:>20}.'     .format( DbU.getValueString( hpitch ) ))
    print( '     - vpitch: {:>20}.'     .format( DbU.getValueString( vpitch ) ))
    print( '     - sliceHeight: {:>15}.'.format( DbU.getValueString( sliceHeight ) ))
    print( '     - sliceStep: {:>17}.'  .format( DbU.getValueString( sliceStep ) ))
    
    rvalue = True
    try:
        #setTraceLevel( 550 )
        #for cell in af.getAllianceLibrary(1).getLibrary().getCells():
        #    print( '"{}" {}'.format(cell.getName(),cell) )
        #Breakpoint.setStopLevel( 100 )
        buildChip = False
        cell, editor = plugins.kwParseMain( **kw )
        cell = af.getCell( CoreName, CRL.Catalog.State.Logical )
        if not cell:
            cell = CRL.Blif.load( CoreName )
        if editor:
            editor.setCell( cell ) 
            editor.setDbuMode( DbU.StringModePhysical )
        ioPadsSpec = [ (IoPin.WEST , None, 'di_0'       , 'DI(0)'  , 'DI(0)'  )
                     , (IoPin.WEST , None, 'di_1'       , 'DI(1)'  , 'DI(1)'  )
                     , (IoPin.WEST , None, 'di_2'       , 'DI(2)'  , 'DI(2)'  )
                     , (IoPin.WEST , None, 'di_3'       , 'DI(3)'  , 'DI(3)'  )
                     , (IoPin.WEST , None, 'allpower_0' , 'iovdd'  , 'vdd'    )
                     , (IoPin.WEST , None, 'allground_0', 'iovss'  , 'vss'    )
                     , (IoPin.WEST , None, 'di_4'       , 'DI(4)'  , 'DI(4)'  )
                     , (IoPin.WEST , None, 'di_5'       , 'DI(5)'  , 'DI(5)'  )
                     , (IoPin.WEST , None, 'di_6'       , 'DI(6)'  , 'DI(6)'  )
                     , (IoPin.WEST , None, 'di_7'       , 'DI(7)'  , 'DI(7)'  )

                     , (IoPin.SOUTH, None, 'do_0'       , 'DO(0)'  , 'DO(0)'  )
                     , (IoPin.SOUTH, None, 'do_1'       , 'DO(1)'  , 'DO(1)'  )
                     , (IoPin.SOUTH, None, 'do_2'       , 'DO(2)'  , 'DO(2)'  )
                     , (IoPin.SOUTH, None, 'do_3'       , 'DO(3)'  , 'DO(3)'  )
                     , (IoPin.SOUTH, None, 'allpower_1' , 'iovdd'  , 'vdd'    )
                     , (IoPin.SOUTH, None, 'allground_1', 'iovss'  , 'vss'    )
                     , (IoPin.SOUTH, None, 'do_4'       , 'DO(4)'  , 'DO(4)'  )
                     , (IoPin.SOUTH, None, 'do_5'       , 'DO(5)'  , 'DO(5)'  )
                     , (IoPin.SOUTH, None, 'do_6'       , 'DO(6)'  , 'DO(6)'  )
                     , (IoPin.SOUTH, None, 'do_7'       , 'DO(7)'  , 'DO(7)'  )
                     , (IoPin.SOUTH, None, 'a_0'        , 'A(0)'   , 'A(0)'   )
                     , (IoPin.SOUTH, None, 'a_1'        , 'A(1)'   , 'A(1)'   )

                     , (IoPin.EAST , None, 'a_2'        , 'A(2)'   , 'A(2)'   )
                     , (IoPin.EAST , None, 'a_3'        , 'A(3)'   , 'A(3)'   )
                     , (IoPin.EAST , None, 'a_4'        , 'A(4)'   , 'A(4)'   )
                     , (IoPin.EAST , None, 'a_5'        , 'A(5)'   , 'A(5)'   )
                     , (IoPin.EAST , None, 'a_6'        , 'A(6)'   , 'A(6)'   )
                     , (IoPin.EAST , None, 'allpower_2' , 'iovdd'  , 'vdd'    )
                     , (IoPin.EAST , None, 'allground_2', 'iovss'  , 'vss'    )
                     , (IoPin.EAST , None, 'a_7'        , 'A(7)'   , 'A(7)'   )
                     , (IoPin.EAST , None, 'a_8'        , 'A(8)'   , 'A(8)'   )
                     , (IoPin.EAST , None, 'a_9'        , 'A(9)'   , 'A(9)'   )
                     , (IoPin.EAST , None, 'a_10'       , 'A(10)'  , 'A(10)'  )
                     , (IoPin.EAST , None, 'a_11'       , 'A(11)'  , 'A(11)'  )
                     , (IoPin.EAST , None, 'a_12'       , 'A(12)'  , 'A(12)'  )
                     , (IoPin.EAST , None, 'a_13'       , 'A(13)'  , 'A(13)'  )

                     , (IoPin.NORTH, None, 'irq'        , 'IRQ'    , 'IRQ'    )
                     , (IoPin.NORTH, None, 'nmi'        , 'NMI'    , 'NMI'    )
                     , (IoPin.NORTH, None, 'rdy'        , 'RDY'    , 'RDY'    )
                     , (IoPin.NORTH, None, 'clk'        , 'clk'    , 'clk'    )
                     , (IoPin.NORTH, None, 'allpower_3' , 'iovdd'  , 'vdd'    )
                     , (IoPin.NORTH, None, 'allground_3', 'iovss'  , 'vss'    )
                     , (IoPin.NORTH, None, 'reset'      , 'reset'  , 'reset'  )
                     , (IoPin.NORTH, None, 'we'         , 'WE'     , 'WE'     )
                     , (IoPin.NORTH, None, 'a_14'       , 'a(14)'  , 'A(14)'  )
                     , (IoPin.NORTH, None, 'a_15'       , 'a(15)'  , 'A(15)'  )
                     ]


        vpitchedSliceHeight = sliceHeight - sliceHeight%hpitch
        hpitchedSliceHeight = sliceHeight - sliceHeight%vpitch
        h,v =  ( (scalar_a - connectors_margin) * sliceStep,  (scalar_b - connectors_margin) * sliceHeight )
        L = generate_ioPinsSpec_list(dico,h,v,vpitchedSliceHeight,hpitchedSliceHeight)
        m2pitch=vpitchedSliceHeight
        m1pitch=hpitchedSliceHeight
        M =[]
        for i in range(len(L)):
            S= L[i]
            tup= (eval(S[0]),S[1],eval(S[2]),eval(S[3]),eval(S[4]))
            M.append(tup)
        ioPinsSpec 	= M
        print(M)

        #ioPinsSpec = [ (IoPin.WEST |IoPin.A_BEGIN, 'DI({})'  ,    vpitchedSliceHeight, vpitchedSliceHeight,  8)
        #             , (IoPin.WEST |IoPin.A_BEGIN, 'DO({})'  , 14*vpitchedSliceHeight, vpitchedSliceHeight,  8)
        #             , (IoPin.EAST |IoPin.A_BEGIN, 'A({})'   ,    vpitchedSliceHeight, vpitchedSliceHeight, 16)
        #             
        #            #, (IoPin.NORTH|IoPin.A_BEGIN, 'clk'     , 10*hpitchedSliceHeight,      0 ,  1)
        #             , (IoPin.NORTH|IoPin.A_BEGIN, 'IRQ'     , 11*hpitchedSliceHeight,      0 ,  1)
        #             , (IoPin.NORTH|IoPin.A_BEGIN, 'NMI'     , 12*hpitchedSliceHeight,      0 ,  1)
        #             , (IoPin.NORTH|IoPin.A_BEGIN, 'RDY'     , 13*hpitchedSliceHeight,      0 ,  1)
        #             , (IoPin.NORTH|IoPin.A_BEGIN, 'WE'      , 14*hpitchedSliceHeight,      0 ,  1)
        #            #, (IoPin.NORTH|IoPin.A_BEGIN, 'reset'   , 15*hpitchedSliceHeight,      0 ,  1)
        #             ]
       #ioPinsSpec = []
        designConf = ChipConf( cell, ioPins=ioPinsSpec, ioPads=ioPadsSpec ) 
        designConf.cfg.tramontana.mergeSupplies    = True
        designConf.cfg.etesian.bloat               = 'disabled'
       #designConf.cfg.etesian.bloat               = 'nsxlib'
        designConf.cfg.etesian.densityVariation    = 0.05
        designConf.cfg.etesian.aspectRatio         = 1.0
       # etesian.spaceMargin is ignored if the coreSize is directly set.
       #designConf.cfg.etesian.spaceMargin         = 0.10
       #designConf.cfg.anabatic.searchHalo         = 2
        designConf.cfg.anabatic.globalIterations   = 6
        designConf.cfg.katana.hTracksReservedLocal = 15
        designConf.cfg.katana.vTracksReservedLocal = 15
        designConf.cfg.katana.hTracksReservedMin   = 6
        designConf.cfg.katana.vTracksReservedMin   = 6
        designConf.cfg.katana.trackFill            = 0
        designConf.cfg.katana.runRealignStage      = False
        designConf.cfg.block.spareSide             = 16*sliceHeight
        designConf.cfg.chip.padCoreSide            = 'North'
        designConf.editor              = editor
        designConf.useSpares           = True
        designConf.useHFNS             = False
        designConf.bColumns            = 2
        designConf.bRows               = 2
        designConf.chipName            = 'chip'
        designConf.chipConf.ioPadGauge = 'LEF.IO_Site'
        designConf.coreToChipClass     = CoreToChip
        designConf.coreSize            = (  scalar_a*sliceStep,  scalar_b*sliceHeight )
        designConf.chipSize            = ( u(16*85 + 2*260.0 + 40.0), u(18*85 + 2*260.0) )
        if buildChip:
            designConf.useHTree( 'clk_from_pad', Spares.HEAVY_LEAF_LOAD )
            designConf.useHTree( 'reset_from_pad' )
            chipBuilder = Chip( designConf )
            chipBuilder.doChipNetlist()
            chipBuilder.doChipFloorplan()
            rvalue = chipBuilder.doPnR()
            CRL.Gds.load( chipBuilder.conf.chip.getLibrary()
                        , 'chip_r_seal.gds'
                        , CRL.Gds.Layer_0_IsBoundary )
            with overlay.UpdateSession():
                chipCell = chipBuilder.conf.chip
                sealCell = chipBuilder.conf.chip.getLibrary().getCell( 'sealring_top' )
                chipAb = chipCell.getAbutmentBox()
                sealAb = sealCell.getAbutmentBox()
                sealX  = (chipAb.getWidth () - sealAb.getWidth ()) // 2
                sealY  = (chipAb.getHeight() - sealAb.getHeight()) // 2
                Instance.create( chipCell
                               , 'sealring'
                               , sealCell
                               , Transformation( sealX, sealY, Transformation.Orientation.ID )
                               , Instance.PlacementStatus.FIXED
                               )
            chipBuilder.save()
        else:
            designConf.useHTree( 'clk', Spares.HEAVY_LEAF_LOAD )
            designConf.useHTree( 'resetn' )
            blockBuilder = Block( designConf )
            rvalue = blockBuilder.doPnR()
            blockBuilder.save()
    except Exception as e:
        catch( e )
        rvalue = False
    sys.stdout.flush()
    sys.stderr.flush()
    return rvalue


if __name__ == '__main__':
    rvalue = scriptMain()
    shellRValue = 0 if rvalue else 1
    sys.exit( shellRValue )
