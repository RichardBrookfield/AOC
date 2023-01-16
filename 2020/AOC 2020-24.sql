USE [Richard];

SET NOCOUNT ON;

-- Test
DECLARE @inputT	varchar(MAX) = '
sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
eesenwseswswnenwswnwnwsewwnwsene
sewnenenenesenwsewnenwwwse
wenwwweseeeweswwwnwwe
wsweesenenewnwwnwsenewsenwwsesesenwne
neeswseenwwswnwswswnw
nenwswwsewswnenenewsenwsenwnesesenew
enewnwewneswsewnwswenweswnenwsenwsw
sweneswneswneneenwnewenewwneswswnese
swwesenesewenwneswnwwneseswwne
enesenwswwswneneswsenwnewswseenwsese
wnwnesenesenenwwnenwsewesewsesesew
nenewswnwewswnenesenwnesewesw
eneswnwswnwsenenwnwnwwseeswneewsenese
neswnwewnwnwseenwseesewsenwsweewe
wseweeenwnesenwwwswnew
';

-- Puzzle
DECLARE @input	varchar(MAX) = '
enesenwwwsenewswsewenwwnwwnwnwswse
swneswseesweswneswwwwseewnewswsw
neneenenenenwneseneesenewenenwnenenesw
weeswnenenwneneeesweneswenwneene
nwnwnenwnwwnwnwnwnwwsewnwswnwwnwnwnw
nwwwnwnwnenenwewnwseewnwswnwwnww
senwweneewewswweswsenwnesenwwnwswnw
nwnwnenenenenwnesenenenwneswnwnweeswwsene
wswnwswneneswswswswswnesweseswwswnwswsw
neeeeeweseesesweeneweneesw
wwenewwwwwwnwnwwwwwwwwse
swneswswseseswswswsw
seswswsewseesesese
nenwneneneewseneneneenenenenenesenenew
swswwwnewwsewwwswwwswswwnesew
wwswwwwwwwwwwwswewwwwe
senewnwwnwswnwswnwewnenwenwewsenwnwse
wnwnwenwwnwnwwnewnwswsenwnwnwnwwne
nenwneswnwnwswnwnwesewwnwnwnwsenwnene
wsewneeseneseseseswnesesenwswenwswnwe
nesewnwwwswnweneenwswwesenesw
swsesenwswsesesewswswneseseeswnesesesewsw
neneswswwswswwswseswswewwswswswsew
eeeneeneneneneesweenewneneeee
seeenesesweseeeewwneeseeseee
nweeweeneeswenewe
seswwnwseeswseseswswe
wneneeswnesenwseneeneneneenwneneneenwne
newnenesenenenenenewneswnenenenenenenenese
wswswswswwswwwwweswnwswsewswswsw
eeeeeenesenwewseeneeneneweee
sewnwwnwnwwwnwnwnwnwswwwewnwww
sewesenwswwneswnwnwnwsweseseeswwse
nwwewnwweswswwwwewnwnwnwwnwwswe
swwwswnwswswenwneswswseswsweswseswsene
eneeenwswseseeeeeesenwenwwsweee
swseenwseesewnwnewnwneeeswswesenee
swwsesenwnwnwwwwnewenwnwewwwwsw
seeeeeeeeswnweeenwnwnewswesw
seenwswnenenwnewnwnwnwnwe
esenenweeswseeeseeweseseeeee
swswswswseswswswswnenw
neneseswsenenewneenenewwnenenenenenenene
wnewwenweswswwwswseswswwwnesene
seneneneweenwnwseeeweeseseeeene
neenwsweneneeeswwnwwneeenewnene
seseneswwneswseswwsesenwseseseswsesese
wweeeeeeswsenweeneeee
newnenenwneseneneeneeneneseneneeneene
wewnwnwwwwwwsenewnwwnwnwwwse
weseeseseswnwsewseneneeeesewwe
swswswswswswswswswswswwneswswwwswswe
swsenwneeseswseswswswswseseneseswswswsw
seswnenwwswswswneswsewwnewseswswwwsw
swswswneswswseswnwswseswseswswseneseswsw
wwwwnewesesewswwwnewwwne
enweeneseneeeeswnwesw
eesesenwseseeseseesesese
nwswseenesewwseesenee
wwswswswwswswwneesw
newwseswwnewswwwwswnwewnewwsww
nesenenenewenesenenenenwnwswnenwnwnenene
swnwswswneswswneswswswswseswswseswsweswwsw
swswswswswswneseswswseswnwswswswsweswsw
nwwwwswwwsewwwwewnwewswwww
neneeneeewneeneeeneenene
swnwnwnwneswwwseeenewnewswsenwwnww
nenenenwnenwneswnenwnenenenenene
nwweenwesweeeeeeseeeeewnenese
weeeneeseeeseeeseeeewe
wwwwwnwesewwwswewwwwenww
seneseseseseseneswsesesesewsewsesesese
eenwneneseeeeeesweenweeeenee
neseneseseseseseeseswseeeeseewee
nwswnweeeeseeseneeneneswswneneee
sesesewseseswesesesewseeneeseesese
seswnewwswewnwswneneswwnwnwnew
wneseneeeewsesewneneneenenwswnwne
wnwnenwnwnwnwsenenwnesenwnwnwnwnwnwnwnwwnw
wwnewnwwswweswewswseeewenwsw
eneeneseeneneneewneweeeneeeneew
nwwnwnwwnwnwenenwnwnwenwnenwnenwnenw
nwsenwnwenwnwswsenwsenwnwnwnwnwnwswenwnw
eeseseeeeeseseeeneesenwseeswe
ewenewneeneswewneseneswsewswwese
nwwwwswwswswwse
newnwnwnwwwwnwnwswsewewnwwwwnwnw
seswswnwwseseseswseesw
sewseweswwwwwswwwwwswwwwnwne
senenenenwnwnwnwnwnwnwnwnw
swswswwwwswswwnwwwswwesewwww
seeneseseneseesesesewsesesesesenwseswsw
wnenwnwsewwwnwnwwwwwsewwnwnew
swswswswswneswseswswswseseseswswnwsesese
neneneneneeneenenesenenwnenewnesenenee
wseseswseneeseswneseswseswswwwseswne
nenenenenenenwnenenenesenesewswneneenwe
seeseseseeseneesesenweeewseewsese
neeewneneneneseneenenenenenenesenwne
nenewnweneweseenwnwsesewnwswnwnwnw
sewnwnesenenwneswwnenwnwnwsenweneswe
senwnwnenwswnwnwnwnenwenenwnwnenenesenw
wnwwwwwsewnwwwewwwweseww
swnwnewnwnwsenwsenwnwnwnenwneswwwnwenenw
wnwseswnewwweewneneeseseesenww
wseseseseeseseseseseesesesenwswswswnw
neneneneneneneseneswnenenwneneneneneenewne
neswswswswswswsesesesesewsewneswsenesw
nenwneswnwweseeenwnesweneeneeese
seesesesesesweeseseseesweenweseenwse
seeswseseseswseseseswswswnenwswswseswsw
swneswswseswswswwswswnwswseswswswswseneswsw
nwseseesesewneeseseeeeeseewenesese
nenenenewneneswneswneneswswneneneneene
nwswnwnenwnwnwnwswnewnwnwnwenwnwnwnww
nwwnwnwnwnenwnwnenwsenenwnenwnwnwnwnw
senenenwnwewwwneeneewnenwsew
nenenenwneneneneswneneneeswenenenwnenw
wwneweewseswseseneneeseeeseese
neneneeswnenenewneneneneneneswenenene
eeeeewseeeneneneeeeeweenwsw
nwenenwnwswwsenwnwswneswnwnwnenwenenwne
eswwswneswswswswswnwewswswwswswwswswsw
enwwwwnwnwnwwewwnwnwnwnwseeww
seseseneeseseseseneseseewwseesesesese
nenenweneswnewenw
nenenenwneneneseswnwnwsenwenwewnenenwnw
nenenenwnwnwenwnwswnwnwwnwnwnwnwnwsenw
neeneneneeneneneneneneenesw
neeeneeeswnwnenwsewswswnenwsenwnee
wenwwwswenewwwsewswswnewswwew
seseeneeseseseneseseesesewsesewsesesese
swewnwwsenwnwwseewwnwwwnewwnw
wesesweeneeenewnwsweenenwneeesw
nwnwswnwnwnwnwnwenenwnwswnwnwnwnwnwenenw
nwsenwwswnenwneeesenewenwwwnw
ewseeeeenweseseseeeewseeseese
wnwnwsewwnwneswwnwwnwnwwnwwwnwnenw
swswsenwwswwenenenewseswswewswnesw
wnwswsesesesweeswseswswswswswseswswsw
eneeswnwwnwnwsweenwenwnwnewnwswswnwne
seseswswseseswseswsenesesewsenenwsesww
eeeneswnwnwnwneneseneseneenewnenwsee
enweseesweswneeweseenwneeew
newneneneneeneneswsenenewnenenene
eneswwneneenwnenesenewwnenenesenene
swswswswswsesenwswswswswsw
eeeneewewneeeee
swswsesenwswsenwswseswsweswseswnwseswswenw
sweneseswswesenenenwnwwnwnwneswe
wnwnwnwwwwsweneswnwnwnwewwnwww
seseswswswsesenwwseeseswswswswweese
seseeseseseseesesesenwnenwsenwsesesesew
wnwnwswnwwwwwwsewwwnenwwwwe
wnwwsenwneewswnwsenwnenwwnwesenwnewsw
swnenwnenenwnwwnwnesenenwnwnenwnenenenwnw
wwewwwwnwswwwnewwwswwwwnw
neneeeweesesenweneneswneeeewne
swswswseneneswwseseseneseseseswswswswswsw
nwnwnenwswwnwwwwnwwwwsew
swswswswseswsesesenwswsewseseswswesesw
nenwswnwnenwswnenwnwnenwnwnwsenwnwneenw
wseseswswswneseswseseswswsenwswswne
swnesesewseneseswswnwswswswswnwswseswswswsw
wnwnwnwnenwsenwneenwswnwnwnwenwsenwswnw
enenenewnenenwnenenenwnenenenenw
enenwnenwsewwwsweenenewnwnenwene
swwswsewnewswneswswwwswswwswwswwsw
neneswseeneeswewenwwswswweesese
swnwseswsenwsenweewenwsweeneeese
nwenwnwnwnwswnwnenwnwnwnwnwnwnwnwwsenw
seseseseeseseseeeeewesenesesewe
eswsenwnwneswwswwswnwwwwseeswsenwe
enenewnesenewnwnwnwswnwnwnenesenenwnenw
wneneneeneeeeweenewnenesweesene
enewnweneneeneeeswneneeeeenene
nwswsesenwnenwnwwnwnweswswnwnwneeew
eseeewneeneeeeeneeeeeseewene
sewnewwwwwwwsewwwwwwwnwwe
newnenesenweneneneweneenene
swseswswswswswswswswewswswswswswnwneswswsw
eseneneseseeseseeeeseeeeeswsewse
enwneenenewneeneneneswnenenenenenene
nenenwnenenwseneneenwnwnenwnweswnwnww
nwnwenwnwsenwnwnwnwnwwwse
nweswswwswenenweeeseseseeeeeee
nwnenwswnwwnwenwsewwnwneswnwnwnwnwsee
seeseeseseneewswweseseswswwwswswsw
nwnwnesenwenwnwnwnwnwnwwnwneswnwswwnwnw
seseseseswseswesesesesesesenesewswsenw
swswwswseseseseswsewseseneseseswneswswsw
nwnwnwnenwswnwnwnenesenenwnwnenwnwnwnenw
swnewwnwneenwnwenwsenwnwnwsewnwenw
eeenwwweeeewseneeswesenese
swenewneseneswneenwnesenenenwnenewene
nwnenwwwwwnewwwwwwwsesenwwww
seseswneseseseeenewwsese
enwneeeswenewneeeeneeseneeee
seseeseneseeeeeeswwnenwseswsesese
nwnesesenenenwnwnenwnwnenenwnewnwnwnenw
wwswnwnwewewswneseeswswswseneswsw
nwsenwneneneneneneeseewnenenenenesenwse
nesewswswneneswneswseswswnewswswsenese
swswwsesweswnwseseswseseswseseseseswsw
senenwswenwnwnwwnenwsenwnwnwnenwewnwwnw
nenenenwnwneswswneswnenenenenenenenenene
enweneswneneneeswneneeewneenenee
nwnwswnwwnwseesenenwwswwnewwsenwnwnw
neswseseswneeswneneswswneswenwwswwwe
swwneeneeneswwewnwneseeenwnenwnewne
wswwwseenwnewneswwnwwwnwseew
seewwnenenwneswwnenwneseneenenenene
swwsenwswsweseesenwwwswswwnewnesenew
neswswswnenesenenenw
nwwsewwwnwwnewnwwnenwwseswnenwswwnw
nenwneseeewneeeeseneesweneenwsee
seswseswseswnwnwswswseswsweseswswswswse
swwswneswswswswswswneswsweswswswswwswsesw
senesewseseseeewseweseseseeseesese
swnesenenenwneneneswnwnwne
wsesewwenenwsesewneneseseseswsesese
newseswwwswwwnwswweswwewswwww
nweneeneneeswnwwenenesweneseneene
esweneenweeeeseweeeneeewew
neswnweswswnenweseswswnesewswsenwsese
nwnwnwnwnwwenwwwnwnw
swswseseswswswswswswswswswsweswneswswnwsw
neneswnenwnenenenenenwnenwne
seeseseneseseswseseseseswsesesenwsesesese
nwnenwnwseenwnewewswsewnwwswswnew
wseesesweseseeneeenwseeeeeenee
swwwsewesewnewnweenwswswwwwwsw
eeneseseeseseseseswseewse
eeeneseeeeeeswseeenewseeee
swseswswsewenenwnwwnweswne
ewwnenwswnwnenwnwnwnenenwnwenenenwnw
neswswswswswnwswwswsewsw
seseeseswswewsewsenwseseneewsewneee
seswseswenwwnwswwswewnweseswnwnw
sesesenesesesewswseseswneseswsesesesesese
neneneneneseenenewneeneneswwnesenenew
nweeewneenwswneneswnewne
nwwewwswwwseswwswwne
nwnenwnwnwnwsewnwnwwnwewnwnwnwnwwnwnw
seneneneneenenwnewneneneswneenenwswnenese
swseswnwseswswseseseswnwnewseswswswswswsesw
nwnenenwnwnenwnenwnwseswneneenwnesenwne
nenenesweeenenenenewne
eewneeeweeeeseeeneneewene
swsweswswswswswswswswneswnwseswnwwseswsw
wwswwwnwnwewseweswnwnesenwwwew
seeneenenenesenenesweweenenenenwnene
newewseewnwwnwwwsewsenewswswe
sweeseweseseeeseeenesesesenwese
neswewwwseswwwswsww
wewnwnwnwnwnwwwnwwswesenwnwenwsee
seswsewsewseswswenenewseenwnwnwswse
swswseswseswseswswswnwswswnwsenesesw
nwnwsenenenwsewnenenenwsenwnesesenwnwnwnw
swnenwwwwwseswwneewswswwwnesene
seseseswswsesenesesesesesw
eneenwneenenenewswneswnesweee
nwnwneswnenenwsenenenenenenenwnenewnene
seswnewswswswnwswsenwwsweswswnwswesee
swswswswswwswswswewswneswswseswswswneswnw
swswswswswseseswsenwseneesesesesewwsese
seneeesweeeeeeweeeee
senweseeeenweeeenwenwsweeswese
swswneswseewswswnwswswwsenweswswswesw
ewneeeeeneweeeeeeweseesesese
nwseswseneeseeseesweeweseesesee
neeneswnenenewnwnenwnenenenwswneenewne
eswwswswnwnwseeenwweswnwnenwswswse
wwswnewwswnwwwswwneneeswwseswne
neneneneseneneswneneeneeewne
wwwnwwnewsenweseewwwewwnew
neswwsweewneswsenewsesewwsenwsesese
seswwsweenwweseneseneseneeenwwe
senwsesweseseswnwseeseswsenesesenenewsw
swseswswswswnenwswswwswswswswswwswenesw
nesenwnwnwnenwnwnwnenwnewnwnwnwnwnesenw
seswswswwswswwswswswswneswswenewnwswsw
nwnwwnwnwnwnenwenwwwenwswwswnwnwnwnww
neseenesenwnwsenwwneesewnewwswenwnenw
wnenwnwnenenenwnenesenwnenenwnenwnenwe
nwnwnwnwnenwnwnesenwnenwnwnenewnwnenwswe
enwswseeseseseewseeswnweeseeeee
eeeeeesenwseseeee
swsesweweswwswswswswnwnwwswswsw
neseneneeeenwweneenenenene
swwsenwnenenwnesesewneeswwswseswnwswswse
seeenweesesweseeeweeeseeswnw
sewsesesesesenesweesenwswsesw
nwnenwwnwnwswnwnenwnwwnwnenwnwnwnwsenwe
neenenwneeneswnenwneswneeneeneeneene
seseeeweseseeeeseese
nenwnenwnenenenenwswneneneenwnenenenw
wwwwswswwsweswnewwnewsewwwne
wwnenwnwsewnwnenwsenwnwnwnwnwwwnwnwsw
seseseswswsesenwwsenesesesesesesene
nwseswsesenwwswnenesenenwsw
swswsweswswswseweswnwswswneseswswswnwsw
enweesweneeneeneneeeeeneeewe
seswseseseseswsesewseseseswswsenwesese
seswsesesesenwnewsesesesesesesesesesenwsese
swswswnwswswswseswnweswswswsw
newnwwswwneeneneseeneswnenenenwnenwnw
swwswnwwswswnwswwewnwsweswswswseesw
sweswnwswenwwswswwwwsweswswswswswsw
nenenwnwsenesenenwnwnwnenenenenenwnwswnwne
wnwseswwewwnewwswnwnwwswewsesww
seseneseseswsesewswsesesesene
wwnwwwewwwewwwnwwwwwnwsww
wneeneesenwseeeeeweeesweswene
senesenwsweseeseesewseseenesewwsee
nwnwnwsenwnwswesenwenwnwnwnwnwnwnwswnwnwnw
eeweeeeeesweneeeseeneeneee
wwsenweswsewswneswswnweneswneenww
eeneneneeneeeeenewswneneeseenee
swwseseneswseseweseseswneesenesesese
eeeeneneneneneweeee
swsenesewseswsenwnenwsesweswsenwswswswnw
nwnwswsweswnenwnwnwnenenwnwnwnwnwsenenw
swsesweseseseweseeseswnwsesesenwseswsesw
eneeseneswswsweeweewnewne
neneeseenenenewenenenewnenenwswesw
sweeswwewsweewnwenwnwnesesenwesw
swswswswswswneswswswsw
eseseeneeeseewenwweeeeswsesese
swswwnwswnwwwswewweswwwwswswwe
wwewswwnwwwwwswwwwwweww
enenwnwwnwwwwsesese
wwwwnwswwwswswwwewwwew
wnenwneeswneneneseneewsw
sweswnenenwewsesenwsenw
wsewwenwnwnwwwnwwwnwnwwwnwww
eseeeeeeseeeseneeneeewwwee
nwwnwewsewnenenwwnwswwnwwwswnwse
wwswwwwweswwswwswswewwwneww
swnewnwnwnewseswewnesweswswesesw
nwnwnwswnwnenwnwnwnwnwnwewnwenwnwnwnw
swseweswnesewneesenwnesenwwseesew
wenweseesenwseswsesweswnenwneenwse
seeneneneeeenweneene
nwnwnenwneenwneswnenwnwnwnwswnwnwnwnwnw
esesesweswneneneswnwnwnenwneneseww
nwnwwenwnwnenwnenweswwenwnwnwnwnenesw
senewsewswswseseneswseseseseswsesesese
nwnwnwsesenenwneneswnwnwewnesewnenese
neesesewseseneseseseeseeseseesewsese
swnewneswwswswwwnewsesesenwswswnwsew
neseseswswwseseeswsesesesesesewseswse
swsweswseswswneseeswswswnwnwswwwswneswnw
seeeeseswsesesesesenwsesesee
nenenwnwnwnwnwswsenwnwnwne
eswsweswswsweswseswswwnewswwswswswsw
seneswneswswseswswseswswseswswsenenwswswsw
eswswseswnwnwsesewseseswseneeswswnesww
seseseesesenwsesesenesewseseseseseesesew
swswswswnweswswnewswswswswswwneswwswsw
neeswnenenesweeneneeneneeneenenewne
neswwswnwnwnwwseseneneewwsesewsew
eseseswwwseenesenesesenenwwnwseseswee
swswswseseseseswwswneeswswweswnwsesene
neneneneenesenwwweneswnwswwnwswnenwne
neeeneeeseeneswnenenenenwewnee
nwwnwewsenwnwnwenwesenwneewwnwsw
seswewnwwnwwswnwsenwnwswseenesweene
seswseneseswswseseseweesewwswwnesw
neseeneneneswneeneenenenewneneneenw
nwnwsewnwsenesenwwnewenw
senwneneswewnenenesenenenwewwnene
nenwenwwswwwwwwwwwewwwwse
sesenwsesesenwseesesenwnwswswsenewese
eeenenenwnwsweeeeeeeeeeneneswe
swwwseswwseswswwswwneswswwwnwsww
nwnwwnwwnwnesewnenwnwwwwnenwwwesese
seswswnwswseseseswseswneseseseewswsese
seswswneewneneeswswnwswwwswswnweswse
nwnwnwnwwnwsenwnewnwnwnwneenenenwnwnesw
nenwnwnwnwwnwesenwnwnwnwnwsewwnw
neswwnesenwneswwenwnwsenwnweeswsese
wwnwnwsewnenwwswwnwwwnwwnwnwwew
sewswseseneswseseswswneswseneseseswsesw
swwwnwwwswwswwwwwsewwwnwesww
seneswswwswwnwenwnwwswseeswwwwwwsw
neneswneneswnenesenenenewnenwneneneenw
nwswseseneseseswswswnewswseseseweswnesenw
nenenenenwneseneeneneneneneeswnenenwnee
swseneeeeeeeweneswneweeswwnw
nenenwneeneswneseenewnwswwnwenenenw
senenwnwwnwsewsewnesenenwwnewsewww
swweeenenenenewseeeeewsenwnee
nwneeseseseseseseseseseswse
eeeeweeeeweeneeesweneee
swswseseesesesesesewseseseseneswsewnesesw
eeenwseeeswnweeeeeeeeeeeesw
swswswswsweewswswswwsweswseswswnwnww
sesewsenwseeseeseeeenwnweswnesesesw
seseesesesesewseseeswseeseneesesenw
neeenwnenwsweneneseeenee
seenewesenwseseeseseseseee
nwswswsweswswwwwwswswswwswsw
wwwwnewwswnewwwnewwseswseww
eeseseseseseseseseesesesesenwenw
wwewwwwwwwnwwwww
swswswwswnewswneswswseswwswswwwswsw
wswneswswswwwwneswwseswswwswwswswsesw
nwnenwnenwnenenenewneneneseenwsenwswnwne
wnweswenwneeswswweseneseneeeenw
wnwneneneenenwnenenenene
newswwswweeswseseswswwseneswwnew
wsweneeseseseseseseseeseeseseeswene
sesenwseswseseseswseewnwseseswsese
seswnwnwneesenwseneewswnenwee
nwnwnwnwsenwnwnesewwnenenenenenwnenwnwnenw
senewesweeneswewsenwe
sewewswswwwwswnwwwnewwwwwswsww
eeneeeeeneeseneeeneneneeswnwnw
swseswwsewswseseswswseneswswswseseswneswsw
nenenenwneneseneneneneneneeeeneneswnwne
wnwsenwnwnwwsewnwnwnwnwnwewswnenenw
nweeeeeneesweneeeeneeneeswesw
sesewwnewwwwwnwwwnewwseeww
nwswswnwswneswwwnwswswsweeswnweeneee
wwwwwwwwswwwwwsewwnenewww
nenwsenwseeswneswseseswswenwswswseswsww
swswwswnwswwswswwswswwswwwewwnwew
wnwnwnwnewseswwewnwwwnwnwwnwsew
weseeseseseenenewseesewswsesesese
nenenenwnwneswnwneneseneneenwnenwnenew
nwseeeeswnewsewseeeeesesewesee
wwnwwewwwwnwenwnwwwwswnwwww
nwnwnwswnwnwnwenwnwnwnwnwnwnenwnwnwnw
wseswweseseneswnwneseswsewswswseese
neewseeesweeneenee
enwseswswswseseswswswswwswswsenwnwe
sewwnwwewwsewwwwwenwsewwwne
wewswswwnwnenwswneeswnwnesesenwesw
swswnenwneswswswswswswswswwswseneswswswse
wswwswswwswneweswewnwswswwsewwe
wnwwnwwsewswwwwwsenwwwswnenwswnee
seseeswenenesesewsewswneneseseesenwse
sesesesesesesenweneseseseseneswsewswsese
wnwnenenesweneeweneseeeseeene
sewnwwnwnwwnwwwwnwnwwsenwneww
wwswswwnewneseswnewwsenewswwwsew
nenesewneswnwenwwnesw
nweeeeeeseeesenwneswneeweene
nwnwwnwnwnwwnwnwwnwnwwwwew
seseseseseseseseswsenwseswsesesenesesese
seeswnwswnwnwseswsenesesweswse
seseeseseseseeseseenwsewseseswnenesewse
wweswnwwwnwsewwnwnwwnewnwwnwnwenw
neneswswswswswswwswneeswwswseseswswswse
sewnwseseswnwswseswsesenwseswseneseseswe
seseseseseeneseewseswneseeseseseseese
ewswseswnewswwwswwwswewwnew
swwewwswnesenesenwwnewnw
seseneseswsesenwseseswwnesesesewse
newswwswwswswswwswwnewswswswwsesw
wseneeeeswnwneenweneneweeeeeee
wswsewswswneswsewneneneswwwwswwsw
swwneeneswswwwswwwsenwswwneswnene
seeeeneeeeeswenweeeseseswsese
sesweeenwnewnwnwneeenwswsewsenwsw
seswnwseeseewnwswneenwnwseswneesee
neswnwwnwnwswnwnwnwnwnwnwenwnwnwnwnwnw
swseswswswseswswneswsw
neeswneneeswsewnwnwneswewnenwenee
swswseswswseswseswnwseswswweswswswneswswse
seseewseeseeeswseseseneseeewee
eeeeeseeweswwseene
swswswswswswswswswswseewneswswswswswsw
senwwwnewseesesenwnwenwwswnwnenwnwnw
eeeseswneesweeeeenweeeenee
newswnesweneneweneneneene
nesenwnenenwnwswseswenwwwwsww
senewswswwseswswnwwsw
newwwwsewswwwwswnwsewswsw
nwnwwnwnwsenwnwwnwnwnwnwnenwnwwwenw
swsenwnesesesewswswswswswswswswseswswsw
seneseseswwesewseseneseseeese
wwwsewwwwnwnwswwwwwwwewwsw
neewneeswenenenenenenenenenenewnenew
nwnenwenwnwnwnwwnwnwnwnenewnwneenene
enwwwwwwwwwsenwnwwewww
senwnwnwnwnwenenwwswneenesweewswswne
nesesesesewsewnesenwseswseswsenwsesesw
seseswswswseseenwseseneswnwnw
seseseseseseeeseeweeseseswnwsenesenw
nenewwswseseswseenwenesenwwwesenwswse
nwnwnwnwswwnweswenwnwnwnwnwnwnwenwswnw
wwwenwsesewnwnwnenwsenewsenwenwwse
swsewswnwwwswewnw
enwnwsenwnwenwnenwnwnwnwnwwswnwnwwew
';

DECLARE	@inputRaw table
(
	[id]			int				NOT NULL		IDENTITY(1,1)
	,[value]		varchar(100)	NOT NULL
);

INSERT INTO @inputRaw
SELECT	[value]
FROM	STRING_SPLIT(REPLACE(@input, CHAR(13), ''), CHAR(10))
WHERE	LEN([value]) > 0;


SELECT * FROM @inputRaw;