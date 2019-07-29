/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ PathologyTests.swift                                                                             ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Dec07/18        Copyright 2018 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable line_length
// swiftlint:disable identifier_name

import XCTest
@testable import SatelliteKit

class PathologyTests: XCTestCase {

    override func setUp() {    }

    override func tearDown() {    }

    class Pathology: XCTestCase {

        // # check error code 4 (0.0 ... 150.0 ... 5.00)
        func test33333() {

            do {
                let tle = try TLE("",
                                  "1 33333U 05037B   05333.02012661  .25992681  00000-0  24476-3 0  1534",
                                  "2 33333  96.4736 157.9986 9950000 244.0492 110.6523  4.00004038 10708")

                print(String(format: "\n%5d", tle.noradIndex))

                let propagator = selectPropagator(tle: tle)

                let     pv = try propagator.getPVCoordinates(minsAfterEpoch: 5.0)
                print(String(format: " %8.1f %@ <-- SatKit", 5.0, pv.debugDescription()))
                print("      5.0      836.362     3131.219    27739.125    0.806969   -0.303613    1.495581 <-- Vallado")

                print("  epoch+s       r[x]         r[y]         r[z]       v[x]        v[y]        v[z]")

                for mins in stride(from: 0.0, through: 150.0, by: 5.0) {
                    do {
                        let     pv = try propagator.getPVCoordinates(minsAfterEpoch: mins)
                        print(String(format: " %8.1f %@", mins, pv.debugDescription()))

                    } catch { print(error); break }
                }

            } catch { print(error) }
        }

        // # try and check error code 2 but this ... ( 0.0->1440.0 [1.00])
        func test33334() {

            do {
                let tle = try TLE("",
                                  "1 33334U 78066F   06174.85818871  .00000620  00000-0  10000-3 0  6809",
                                  "2 33334  68.4714 236.1303 5602877 123.7484 302.5767  0.00001000 67521")
                let propagator = selectPropagator(tle: tle)

                print(String(format: "\n%5d", tle.noradIndex))
                print("  epoch+s       r[x]         r[y]         r[z]       v[x]        v[y]        v[z]")

                for mins in stride(from: 0.0, through: 1440.0, by: 1.0) {
                    do {
                        let     pv = try propagator.getPVCoordinates(minsAfterEpoch: mins)
                        print(String(format: " %8.1f %@", mins, pv.debugDescription()))

                    } catch { print(error); break }
                }

            } catch { print(error) }

            print("      0.0    23876.970   -37275.653    -8113.951    0.589108   -0.767768   -0.260380 <-- Vallado")
        }

        // # try to check error code 3 looks like ep never goes below zero,
        // # tied close to ecc (0.0->1440.0 [20.00])
        func test33335() {

            do {
                let tle = try TLE("",
                                  "1 33335U 05008A   06176.46683397 -.00000205  00000-0  10000-3 0  2190",
                                  "2 33335   0.0019 286.9433 0000004  13.7918  55.6504  1.00270176  4891")
                let propagator = selectPropagator(tle: tle)

                print(String(format: "\n%5d", tle.noradIndex))
                print("  epoch+s       r[x]         r[y]         r[z]       v[x]        v[y]        v[z]")

                for mins in stride(from: 0.0, through: 1440.0, by: 20.0) {
                    do {
                        let     pv = try propagator.getPVCoordinates(minsAfterEpoch: mins)
                        print(String(format: " %8.1f %@", mins, pv.debugDescription()))

                    } catch { print(error); break }
                }

            } catch { print(error) }

            print("      0.0    42081.344    -2649.185        0.818    0.193185    3.068627    0.000438 <-- Vallado")
        }

        // # Shows Lyddane choice at 1860 and 4700 min (  1844000.0   1845100.0        5.00)
        func test20413() {

            do {
                let tle = try TLE("",
                                  "1 20413U 83020D   05363.79166667  .00000000  00000-0  00000+0 0  7041",
                                  "2 20413  12.3514 187.4253 7864447 196.3027 356.5478  0.24690082  7978")
                let propagator = selectPropagator(tle: tle)

                print(String(format: "\n%5d", tle.noradIndex))
                print("  epoch+s       r[x]         r[y]         r[z]       v[x]        v[y]        v[z]")

                for mins in stride(from: 1844000.0, through: 1845100.0, by: 5.0) {
                    do {
                        let     pv = try propagator.getPVCoordinates(minsAfterEpoch: mins)

                        let     string = String(format: " %8.1f %12.3f %12.3f %12.3f %11.6f %11.6f %11.6f", mins,
                                                (pv.position.x)/1000.0, (pv.position.y)/1000.0, (pv.position.z)/1000.0,
                                                (pv.velocity.x)/1000.0, (pv.velocity.y)/1000.0, (pv.velocity.z)/1000.0)

                        print(string)

                    } catch { print(error); break }
                }

            } catch { print(error) }
        }

    }

    /*

     33333
     epoch+s       r[x]         r[y]         r[z]       v[x]        v[y]        v[z]
     0.0   -12908.671     8084.565    22887.750   -0.076982    0.252652    1.837356
     5.0      836.362     3131.219    27739.125    0.806969   -0.303613    1.495581
     10.0    12529.162    -7305.767    24606.259    1.077047   -0.832176    0.734844
     15.0    17680.278   -19040.503    13889.533    0.838850   -1.010897    0.019846
     20.0    23876.970   -37275.653    -8113.951    0.589108   -0.767768   -0.260380

     33334
     epoch+s       r[x]         r[y]         r[z]       v[x]        v[y]        v[z]
     0.0    23876.970   -37275.653    -8113.951    0.589108   -0.767768   -0.260380

     33335
     epoch+s       r[x]         r[y]         r[z]       v[x]        v[y]        v[z]
     0.0    42081.344    -2649.185        0.818    0.193185    3.068627    0.000438
     20.0    42151.861     1038.565        1.312   -0.075731    3.073769    0.000428
     40.0    41899.825     4718.368        1.788   -0.344067    3.055390    0.000415
     60.0    41327.165     8362.064        2.243   -0.609770    3.013630    0.000399
     80.0    40438.263    11941.773        2.674   -0.870806    2.948810    0.000381
     100.0    39239.921    15430.102        3.079   -1.125180    2.861425    0.000360
     120.0    37741.309    18800.357        3.455   -1.370943    2.752144    0.000337
     140.0    35953.895    22026.749        3.799   -1.606215    2.621804    0.000312
     160.0    33891.356    25084.588        4.110   -1.829196    2.471400    0.000285
     180.0    31569.476    27950.477        4.386   -2.038180    2.302086    0.000256
     200.0    29006.021    30602.485        4.625   -2.231567    2.115155    0.000226
     220.0    26220.609    33020.318        4.826   -2.407878    1.912040    0.000195
     240.0    23234.552    35185.475        4.989   -2.565764    1.694293    0.000163
     260.0    20070.702    37081.388        5.113   -2.704016    1.463581    0.000131
     280.0    16753.268    38693.549        5.198   -2.821576    1.221669    0.000098
     300.0    13307.636    40009.622        5.243   -2.917545    0.970410    0.000065
     320.0     9760.172    41019.537        5.250   -2.991189    0.711725    0.000032
     340.0     6138.023    41715.565        5.219   -3.041944    0.447593    0.000000
     360.0     2468.904    42092.380        5.151   -3.069422    0.180037   -0.000032
     380.0    -1219.107    42147.099        5.046   -3.073412   -0.088897   -0.000063
     400.0    -4897.789    41879.303        4.907   -3.053883   -0.357151   -0.000093
     420.0    -8538.993    41291.042        4.736   -3.010987   -0.622671   -0.000121
     440.0   -12114.855    40386.817        4.533   -2.945049   -0.883427   -0.000148
     460.0   -15598.013    39173.548        4.302   -2.856576   -1.137423   -0.000174
     480.0   -18961.813    37660.518        4.044   -2.746244   -1.382715   -0.000198
     500.0   -22180.515    35859.306        3.762   -2.614898   -1.617426   -0.000219
     520.0   -25229.490    33783.694        3.459   -2.463542   -1.839761   -0.000239
     540.0   -28085.405    31449.566        3.137   -2.293335   -2.048017   -0.000257
     560.0   -30726.408    28874.782        2.799   -2.105578   -2.240602   -0.000272
     580.0   -33132.289    26079.046        2.448   -1.901710   -2.416041   -0.000286
     600.0   -35284.638    23083.749        2.087   -1.683290   -2.572993   -0.000296
     620.0   -37166.985    19911.813        1.718   -1.451989   -2.710256   -0.000305
     640.0   -38764.926    16587.510        1.345   -1.209577   -2.826780   -0.000311
     660.0   -40066.233    13136.278        0.971   -0.957909   -2.921673   -0.000314
     680.0   -41060.950     9584.525        0.598   -0.698912   -2.994208   -0.000315
     700.0   -41741.463     5959.431        0.229   -0.434566   -3.043832   -0.000314
     720.0   -42102.566     2288.734       -0.133   -0.166894   -3.070164   -0.000311
     740.0   -42141.496    -1399.476       -0.486    0.102054   -3.073003   -0.000305
     760.0   -41857.954    -5076.977       -0.826    0.370221   -3.052327   -0.000298
     780.0   -41254.110    -8715.629       -1.153    0.635556   -3.008295   -0.000288
     800.0   -40334.585   -12287.587       -1.464    0.896027   -2.941242   -0.000277
     820.0   -39106.416   -15765.520       -1.756    1.149642   -2.851683   -0.000263
     840.0   -37578.999   -19122.812       -2.028    1.394460   -2.740302   -0.000249
     860.0   -35764.023   -22333.775       -2.278    1.628607   -2.607952   -0.000232
     880.0   -33675.377   -25373.837       -2.506    1.850292   -2.455645   -0.000215
     900.0   -31329.043   -28219.735       -2.709    2.057818   -2.284548   -0.000196
     920.0   -28742.976   -30849.693       -2.887    2.249598   -2.095969   -0.000176
     940.0   -25936.963   -33243.584       -3.039    2.424163   -1.891352   -0.000156
     960.0   -22932.478   -35383.092       -3.165    2.580179   -1.672261   -0.000135
     980.0   -19752.511   -37251.844       -3.264    2.716450   -1.440374   -0.000113

     20413
     epoch+s       r[x]         r[y]         r[z]       v[x]        v[y]        v[z]
     0.0    25123.293   -13225.500     3249.404    0.488683    4.797898   -0.961120
     1844000.0   -35697.350   -70749.925    14190.125    1.649636    1.769994   -0.576290
     1844005.0   -35200.648   -70216.174    14016.779    1.657878    1.786367   -0.579577
     1844010.0   -34701.454   -69677.460    13842.437    1.666228    1.803063   -0.582914
     1844015.0   -34199.734   -69133.685    13667.084    1.674689    1.820093   -0.586300
     1844020.0   -33695.456   -68584.747    13490.703    1.683263    1.837470   -0.589738
     1844025.0   -33188.584   -68030.539    13313.281    1.691954    1.855207   -0.593230
     1844030.0   -32679.083   -67470.952    13134.799    1.700764    1.873318   -0.596776
     1844035.0   -32166.917   -66905.871    12955.242    1.709698    1.891816   -0.600379
     1844040.0   -31652.049   -66335.177    12774.592    1.718758    1.910717   -0.604041
     1844045.0   -31134.439   -65758.748    12592.832    1.727947    1.930038   -0.607763
     1844050.0   -30614.048   -65176.454    12409.943    1.737271    1.949795   -0.611547
     1844055.0   -30090.837   -64588.162    12225.906    1.746732    1.970005   -0.615396
     1844060.0   -29564.762   -63993.733    12040.701    1.756334    1.990689   -0.619311
     1844065.0   -29035.780   -63393.022    11854.308    1.766082    2.011866   -0.623295
     1844070.0   -28503.848   -62785.878    11666.706    1.775979    2.033557   -0.627351
     1844075.0   -27968.920   -62172.142    11477.873    1.786031    2.055786   -0.631480
     1844080.0   -27430.949   -61551.650    11287.788    1.796241    2.078577   -0.635686
     1844085.0   -26889.887   -60924.229    11096.425    1.806615    2.101955   -0.639971
     1844090.0   -26345.683   -60289.699    10903.762    1.817157    2.125947   -0.644338
     1844095.0   -25798.287   -59647.871    10709.773    1.827873    2.150585   -0.648790
     1844100.0   -25247.645   -58998.546    10514.433    1.838768    2.175897   -0.653330
     1844105.0   -24693.703   -58341.517    10317.713    1.849848    2.201919   -0.657963
     1844110.0   -24136.405   -57676.566    10119.586    1.861118    2.228687   -0.662691
     1844115.0   -23575.692   -57003.462     9920.024    1.872584    2.256238   -0.667518
     1844120.0   -23011.505   -56321.966     9718.994    1.884253    2.284614   -0.672448
     1844125.0   -22443.782   -55631.821     9516.467    1.896131    2.313861   -0.677486
     1844130.0   -21872.459   -54932.760     9312.409    1.908225    2.344026   -0.682637
     1844135.0   -21297.471   -54224.499     9106.785    1.920541    2.375161   -0.687904
     1844140.0   -20718.750   -53506.739     8899.560    1.933087    2.407323   -0.693293
     1844145.0   -20136.225   -52779.161     8690.697    1.945870    2.440573   -0.698809
     1844150.0   -19549.824   -52041.431     8480.156    1.958897    2.474978   -0.704459
     1844155.0   -18959.474   -51293.190     8267.896    1.972177    2.510608   -0.710247
     1844160.0   -18365.096   -50534.058     8053.876    1.985717    2.547544   -0.716182
     1844165.0   -17766.612   -49763.631     7838.050    1.999524    2.585872   -0.722269
     1844170.0   -17163.941   -48981.478     7620.371    2.013608    2.625685   -0.728516
     1844175.0   -16556.997   -48187.136     7400.790    2.027975    2.667087   -0.734931
     1844180.0   -15945.695   -47380.112     7179.256    2.042635    2.710193   -0.741522
     1844185.0   -15329.946   -46559.876     6955.715    2.057594    2.755129   -0.748299
     1844190.0   -14709.659   -45725.857     6730.110    2.072859    2.802033   -0.755270
     1844195.0   -14084.742   -44877.442     6502.380    2.088438    2.851063   -0.762447
     1844200.0   -13455.098   -44013.968     6272.463    2.104335    2.902389   -0.769839
     1844205.0   -12820.632   -43134.716     6040.292    2.120557    2.956206   -0.777459
     1844210.0   -12181.246   -42238.906     5805.798    2.137104    3.012730   -0.785319
     1844215.0   -11536.843   -41325.690     5568.906    2.153979    3.072207   -0.793432
     1844220.0   -10887.323   -40394.140     5329.538    2.171178    3.134914   -0.801812
     1844225.0   -10232.591   -39443.241     5087.613    2.188694    3.201165   -0.810474
     1844230.0    -9572.554   -38471.876     4843.044    2.206516    3.271321   -0.819434
     1844235.0    -8907.122   -37478.811     4595.739    2.224624    3.345795   -0.828709
     1844240.0    -8236.213   -36462.680     4345.601    2.242988    3.425064   -0.838314
     1844245.0    -7559.758   -35421.963     4092.529    2.261566    3.509685   -0.848267
     1844250.0    -6877.699   -34354.957     3836.416    2.280296    3.600308   -0.858586
     1844255.0    -6190.005   -33259.749     3577.151    2.299095    3.697698   -0.869286
     1844260.0    -5496.670   -32134.175     3314.618    2.317844    3.802766   -0.880381
     1844265.0    -4797.733   -30975.771     3048.696    2.336381    3.916605   -0.891882
     1844270.0    -4093.290   -29781.712     2779.264    2.354477    4.040535   -0.903793
     1844275.0    -3383.519   -28548.733     2506.199    2.371816    4.176175   -0.916108
     1844280.0    -2668.709   -27273.030     2229.386    2.387950    4.325527   -0.928803
     1844285.0    -1949.313   -25950.123     1948.717    2.402243    4.491107   -0.941826
     1844290.0    -1226.012   -24574.680     1664.110    2.413777    4.676118   -0.955080
     1844295.0     -499.825   -23140.271     1375.519    2.421198    4.884716   -0.968390
     1844300.0      227.731   -21639.030     1082.971    2.422476    5.122396   -0.981456
     1844305.0      954.374   -20061.170      786.614    2.414468    5.396587   -0.993757
     1844310.0     1676.626   -18394.271      486.805    2.392159    5.717597   -1.004375
     1844315.0     2389.050   -16622.200      184.276    2.347197    6.100164   -1.011654
     1844320.0     3082.864   -14723.432     -119.546    2.264946    6.566068   -1.012476
     1844325.0     3743.215   -12668.305     -421.893    2.118033    7.148705   -1.000616
     1844330.0     4343.377   -10414.455     -717.198    1.850804    7.900986   -0.962614
     1844335.0     4831.038    -7899.261     -993.484    1.337298    8.906916   -0.866085
     1844340.0     5091.555    -5030.011    -1222.142    0.252792   10.276494   -0.621814

     */

//    func testPerformanceExample() {
//
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}