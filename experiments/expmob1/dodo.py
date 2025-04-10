
import os
from   pathlib import Path
from   pdks.ihpsg13g2_c4m import setup

setup( checkToolkit=Path('../../..') )

DOIT_CONFIG = { 'verbosity' :0 }

from coriolis                               import CRL
from coriolis.designflow.task               import ShellEnv, Tasks
from coriolis.designflow.yosys              import Yosys
from coriolis.designflow.blif2vst           import Blif2Vst
from coriolis.designflow.klayout            import Klayout
from coriolis.designflow.pnr                import PnR
from coriolis.designflow.lvx                import Lvx
from coriolis.designflow.tasyagle           import TasYagle, STA, XTas
from coriolis.designflow.alias              import Alias
from coriolis.designflow.clean              import Clean
from pdks.ihpsg13g2_c4m.designflow.filler   import Filler
from pdks.ihpsg13g2_c4m.designflow.sealring import SealRing
from pdks.ihpsg13g2_c4m.designflow.drc      import DRC
from doDesign                               import scriptMain

buildChip          = False
PnR.textMode       = True
pnrSuffix          = '_cts_r'
topName            = 'expmob1'
TasYagle.ClockName = 'clk'

ruleYosys = Yosys   .mkRule( 'yosys', f'{topName}.v' )
ruleB2V   = Blif2Vst.mkRule( 'b2v'  , f'{topName}.vst', [ruleYosys], flags=0 )

if buildChip:
    # Rule for chip generation.
    ruleSeal  = SealRing.mkRule( 'sealring', targets=[ 'chip_r_seal.gds' ] , size=[2200.0, 2200.0] )
    rulePnR   = PnR.mkRule( 'gds'  , [ 'chip_r.gds'
                                     , 'chip_r.vst'
                                     , 'chip_r.spi'
                                     , 'chip.vst'
                                     , 'chip.spi'
                                     , 'corona_cts_r.vst'
                                     , 'corona_cts_r.spi'
                                     , 'corona.vst'
                                     , 'corona.spi'
                                     , f'{topName}_cts.spi'
                                     , f'{topName}_cts.vst' ]
                                     , [ruleB2V, ruleSeal]
                                   , scriptMain
                                   , topName=topName )
    staLayout = rulePnR.file_target( 6 )
else:
    # Rule for block generation.
    rulePnR = PnR.mkRule( 'gds'    , [ f'{topName}_cts_r.gds'
                                     , f'{topName}_cts_r.vst'
                                     , f'{topName}_cts_r.spi' ]
                                     , [ruleB2V]
                                   , scriptMain
                                   , topName=topName )
    ruleLvx = Lvx.mkRule( 'lvx_spi', [ f'{topName}_cts_r.vst'
                                     , f'{topName}_cts_r.spi' ]
                                   , Lvx.MergeSupply|Lvx.Flatten )
    staLayout = rulePnR.file_target( 2 )

ruleDrcMin  = DRC    .mkRule( 'drc_min', rulePnR.file_target(0), DRC.Minimal )
ruleDrcMax  = DRC    .mkRule( 'drc_max', rulePnR.file_target(0), DRC.Maximal )
ruleDrcC4M  = DRC    .mkRule( 'drc_c4m', rulePnR.file_target(0), DRC.C4M )
ruleSTA     = STA    .mkRule( 'sta'    , staLayout )
ruleXTas    = XTas   .mkRule( 'xtas'   , ruleSTA.file_target(0) )
ruleCgt     = PnR    .mkRule( 'cgt' )
ruleKlayout = Klayout.mkRule( 'klayout', depends=rulePnR.file_target(0) )
ruleClean   = Clean  .mkRule( [ 'lefRWarning.log', 'cgt.log' ] )
