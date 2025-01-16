
import swift

from Method m, NominalTypeDecl d, string path
where d = m.getDeclaringDecl()
and m.hasLocation()
and path = m.getFile().getRelativePath()
and
path.regexpMatch(
  "^(Loop|LoopKit|LibreTransmitter|" +
  "AmplitudeService|CGMBLEKit|G7SensorKit|LogglyService|" +
  "LoopOnboarding|LoopSupport|MinimedKit|Minizip|MixpanelService|" +
  "NightscoutRemoteCGM|NightscoutService|OmniBLE|OmniKit|" +
  "OverrideAssetsLoop\\.xcassets|OverrideAssetsWatchApp\\.xcassets|" +
  "RileyLinkKit|Scripts|TidepoolService|TrueTime\\.swift|" +
  "dexcom-share-client-swift|docs|fastlane|patches)" +
  "(/.*|$)"
)
select m, 
       d.getName() + "." + m.getName() + " in " + path
       


       