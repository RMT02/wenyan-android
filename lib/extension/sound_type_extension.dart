import '../gen/assets.gen.dart';
import '../model/sound_settings.dart';

extension SoundTypeExtension on SoundType {
  String get asset => switch (this) {
    SoundType.syuiloNAec =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nAec,
    SoundType.syuiloNAec4va =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nAec4va,
    SoundType.syuiloNAec4vb =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nAec4vb,
    SoundType.syuiloNAec8va =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nAec8va,
    SoundType.syuiloNAec8vb =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nAec8vb,
    SoundType.syuiloNCea =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nCea,
    SoundType.syuiloNCea4va =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nCea4va,
    SoundType.syuiloNCea4vb =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nCea4vb,
    SoundType.syuiloNCea8va =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nCea8va,
    SoundType.syuiloNCea8vb =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nCea8vb,
    SoundType.syuiloNEca =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nEca,
    SoundType.syuiloNEca4va =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nEca4va,
    SoundType.syuiloNEca4vb =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nEca4vb,
    SoundType.syuiloNEca8va =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nEca8va,
    SoundType.syuiloNEca8vb =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nEca8vb,
    SoundType.syuiloNEa =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nEa,
    SoundType.syuiloNEa4va =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nEa4va,
    SoundType.syuiloNEa4vb =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nEa4vb,
    SoundType.syuiloNEa8va =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nEa8va,
    SoundType.syuiloNEa8vb =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nEa8vb,
    SoundType.syuiloNEaHarmony =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.nEaHarmony,
    SoundType.syuiloUp =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.up,
    SoundType.syuiloDown =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.down,
    SoundType.syuiloPope1 =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.pope1,
    SoundType.syuiloPope2 =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.pope2,
    SoundType.syuiloWaon =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.waon,
    SoundType.syuiloPopo =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.popo,
    SoundType.syuiloTriple =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.triple,
    SoundType.syuiloBubble1 =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.bubble1,
    SoundType.syuiloBubble2 =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.bubble2,
    SoundType.syuiloPoi1 =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.poi1,
    SoundType.syuiloPoi2 =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.poi2,
    SoundType.syuiloPirori =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.pirori,
    SoundType.syuiloPiroriWet =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.piroriWet,
    SoundType.syuiloPiroriSquareWet =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.piroriSquareWet,
    SoundType.syuiloSquarePico =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.squarePico,
    SoundType.syuiloReverved =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.reverved,
    SoundType.syuiloRyukyu =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.ryukyu,
    SoundType.syuiloKick =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.kick,
    SoundType.syuiloSnare =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.snare,
    SoundType.syuiloQueueJammed =>
      Assets.wenyan.packages.frontend.assets.sounds.syuilo.queueJammed,
    SoundType.aisha1 => Assets.wenyan.packages.frontend.assets.sounds.aisha.a1,
    SoundType.aisha2 => Assets.wenyan.packages.frontend.assets.sounds.aisha.a2,
    SoundType.aisha3 => Assets.wenyan.packages.frontend.assets.sounds.aisha.a3,
    SoundType.noizenecioKickGaba1 =>
      Assets.wenyan.packages.frontend.assets.sounds.noizenecio.kickGaba1,
    SoundType.noizenecioKickGaba2 =>
      Assets.wenyan.packages.frontend.assets.sounds.noizenecio.kickGaba2,
    SoundType.noizenecioKickGaba3 =>
      Assets.wenyan.packages.frontend.assets.sounds.noizenecio.kickGaba3,
    SoundType.noizenecioKickGaba4 =>
      Assets.wenyan.packages.frontend.assets.sounds.noizenecio.kickGaba4,
    SoundType.noizenecioKickGaba5 =>
      Assets.wenyan.packages.frontend.assets.sounds.noizenecio.kickGaba5,
    SoundType.noizenecioKickGaba6 =>
      Assets.wenyan.packages.frontend.assets.sounds.noizenecio.kickGaba6,
    SoundType.noizenecioKickGaba7 =>
      Assets.wenyan.packages.frontend.assets.sounds.noizenecio.kickGaba7,
  };

  String get name => switch (this) {
    SoundType.syuiloNAec => 'syuilo/n-aec',
    SoundType.syuiloNAec4va => 'syuilo/n-aec-4va',
    SoundType.syuiloNAec4vb => 'syuilo/n-aec-4vb',
    SoundType.syuiloNAec8va => 'syuilo/n-aec-8va',
    SoundType.syuiloNAec8vb => 'syuilo/n-aec-8vb',
    SoundType.syuiloNCea => 'syuilo/n-cea',
    SoundType.syuiloNCea4va => 'syuilo/n-cea-4va',
    SoundType.syuiloNCea4vb => 'syuilo/n-cea-4vb',
    SoundType.syuiloNCea8va => 'syuilo/n-cea-8va',
    SoundType.syuiloNCea8vb => 'syuilo/n-cea-8vb',
    SoundType.syuiloNEca => 'syuilo/n-eca',
    SoundType.syuiloNEca4va => 'syuilo/n-eca-4va',
    SoundType.syuiloNEca4vb => 'syuilo/n-eca-4vb',
    SoundType.syuiloNEca8va => 'syuilo/n-eca-8va',
    SoundType.syuiloNEca8vb => 'syuilo/n-eca-8vb',
    SoundType.syuiloNEa => 'syuilo/n-ea',
    SoundType.syuiloNEa4va => 'syuilo/n-ea-4va',
    SoundType.syuiloNEa4vb => 'syuilo/n-ea-4vb',
    SoundType.syuiloNEa8va => 'syuilo/n-ea-8va',
    SoundType.syuiloNEa8vb => 'syuilo/n-ea-8vb',
    SoundType.syuiloNEaHarmony => 'syuilo/n-ea-harmony',
    SoundType.syuiloUp => 'syuilo/up',
    SoundType.syuiloDown => 'syuilo/down',
    SoundType.syuiloPope1 => 'syuilo/pope1',
    SoundType.syuiloPope2 => 'syuilo/pope2',
    SoundType.syuiloWaon => 'syuilo/waon',
    SoundType.syuiloPopo => 'syuilo/popo',
    SoundType.syuiloTriple => 'syuilo/triple',
    SoundType.syuiloBubble1 => 'syuilo/bubble1',
    SoundType.syuiloBubble2 => 'syuilo/bubble2',
    SoundType.syuiloPoi1 => 'syuilo/poi1',
    SoundType.syuiloPoi2 => 'syuilo/poi2',
    SoundType.syuiloPirori => 'syuilo/pirori',
    SoundType.syuiloPiroriWet => 'syuilo/pirori-wet',
    SoundType.syuiloPiroriSquareWet => 'syuilo/pirori-square-wet',
    SoundType.syuiloSquarePico => 'syuilo/square-pico',
    SoundType.syuiloReverved => 'syuilo/reverved',
    SoundType.syuiloRyukyu => 'syuilo/ryukyu',
    SoundType.syuiloKick => 'syuilo/kick',
    SoundType.syuiloSnare => 'syuilo/snare',
    SoundType.syuiloQueueJammed => 'syuilo/queue-jammed',
    SoundType.aisha1 => 'aisha/1',
    SoundType.aisha2 => 'aisha/2',
    SoundType.aisha3 => 'aisha/3',
    SoundType.noizenecioKickGaba1 => 'noizenecio/kick_gaba1',
    SoundType.noizenecioKickGaba2 => 'noizenecio/kick_gaba2',
    SoundType.noizenecioKickGaba3 => 'noizenecio/kick_gaba3',
    SoundType.noizenecioKickGaba4 => 'noizenecio/kick_gaba4',
    SoundType.noizenecioKickGaba5 => 'noizenecio/kick_gaba5',
    SoundType.noizenecioKickGaba6 => 'noizenecio/kick_gaba6',
    SoundType.noizenecioKickGaba7 => 'noizenecio/kick_gaba7',
  };
}
