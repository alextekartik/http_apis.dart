import 'package:cv/cv_json.dart';
import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:test/test.dart';

var fillOptions = CvFillOptions(valueStart: 0, collectionSize: 1);

Model fillModel<T extends CvModel>() {
  return (newModel().cv<T>()..fillModel(fillOptions)).toMap();
}

void main() {
  initDeezerCvBuilders();
  test('artist', () {
    var map = {
      'id': '27',
      'name': 'Daft Punk',
      'link': 'https://www.deezer.com/artist/27',
      'share':
          'https://www.deezer.com/artist/27?utm_source=deezer&utm_content=artist-27&utm_term=0_1681898970&utm_medium=web',
      'picture': 'https://api.deezer.com/artist/27/image',
      'picture_small':
          'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/56x56-000000-80-0-0.jpg',
      'picture_medium':
          'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/250x250-000000-80-0-0.jpg',
      'picture_big':
          'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/500x500-000000-80-0-0.jpg',
      'picture_xl':
          'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/1000x1000-000000-80-0-0.jpg',
      'nb_album': 35,
      'nb_fan': 4425151,
      'radio': true,
      'tracklist': 'https://api.deezer.com/artist/27/top?limit=50',
      'type': 'artist'
    };
    var artist = map.cv<DeezerArtist>();
    expect(artist.id.v, '27');
    expect(artist.name.v, 'Daft Punk');
    expect(artist.toMap(), {
      'id': '27',
      'name': 'Daft Punk',
      'picture': 'https://api.deezer.com/artist/27/image',
      'picture_small':
          'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/56x56-000000-80-0-0.jpg',
      'picture_medium':
          'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/250x250-000000-80-0-0.jpg'
    });
  });
  test('track', () {
    var map = {
      'id': '3135556',
      'readable': true,
      'title': 'Harder, Better, Faster, Stronger',
      'title_short': 'Harder, Better, Faster, Stronger',
      'title_version': '',
      'isrc': 'GBDUW0000059',
      'link': 'https://www.deezer.com/track/3135556',
      'share':
          'https://www.deezer.com/track/3135556?utm_source=deezer&utm_content=track-3135556&utm_term=0_1681899158&utm_medium=web',
      'duration': '224',
      'track_position': 4,
      'disk_number': 1,
      'rank': '778628',
      'release_date': '2005-01-24',
      'explicit_lyrics': false,
      'explicit_content_lyrics': 0,
      'explicit_content_cover': 0,
      'preview':
          'https://cdns-preview-d.dzcdn.net/stream/c-deda7fa9316d9e9e880d2c6207e92260-10.mp3',
      'bpm': 123.4,
      'gain': -12.4,
      'contributors': [
        {
          'id': 27,
          'name': 'Daft Punk',
          'link': 'https://www.deezer.com/artist/27',
          'share':
              'https://www.deezer.com/artist/27?utm_source=deezer&utm_content=artist-27&utm_term=0_1681899158&utm_medium=web',
          'picture': 'https://api.deezer.com/artist/27/image',
          'picture_small':
              'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/56x56-000000-80-0-0.jpg',
          'picture_medium':
              'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/250x250-000000-80-0-0.jpg',
          'picture_big':
              'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/500x500-000000-80-0-0.jpg',
          'picture_xl':
              'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/1000x1000-000000-80-0-0.jpg',
          'radio': true,
          'tracklist': 'https://api.deezer.com/artist/27/top?limit=50',
          'type': 'artist',
          'role': 'Main'
        }
      ],
      'md5_image': '2e018122cb56986277102d2041a592c8',
      'artist': {
        'id': '27',
        'name': 'Daft Punk',
        'link': 'https://www.deezer.com/artist/27',
        'share':
            'https://www.deezer.com/artist/27?utm_source=deezer&utm_content=artist-27&utm_term=0_1681899158&utm_medium=web',
        'picture': 'https://api.deezer.com/artist/27/image',
        'picture_small':
            'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/56x56-000000-80-0-0.jpg',
        'picture_medium':
            'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/250x250-000000-80-0-0.jpg',
        'picture_big':
            'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/500x500-000000-80-0-0.jpg',
        'picture_xl':
            'https://e-cdns-images.dzcdn.net/images/artist/f2bc007e9133c946ac3c3907ddc5d2ea/1000x1000-000000-80-0-0.jpg',
        'radio': true,
        'tracklist': 'https://api.deezer.com/artist/27/top?limit=50',
        'type': 'artist'
      },
      'album': {
        'id': '302127',
        'title': 'Discovery',
        'link': 'https://www.deezer.com/album/302127',
        'cover': 'https://api.deezer.com/album/302127/image',
        'cover_small':
            'https://e-cdns-images.dzcdn.net/images/cover/2e018122cb56986277102d2041a592c8/56x56-000000-80-0-0.jpg',
        'cover_medium':
            'https://e-cdns-images.dzcdn.net/images/cover/2e018122cb56986277102d2041a592c8/250x250-000000-80-0-0.jpg',
        'cover_big':
            'https://e-cdns-images.dzcdn.net/images/cover/2e018122cb56986277102d2041a592c8/500x500-000000-80-0-0.jpg',
        'cover_xl':
            'https://e-cdns-images.dzcdn.net/images/cover/2e018122cb56986277102d2041a592c8/1000x1000-000000-80-0-0.jpg',
        'md5_image': '2e018122cb56986277102d2041a592c8',
        'release_date': '2001-03-07',
        'tracklist': 'https://api.deezer.com/album/302127/tracks',
        'type': 'album'
      },
      'type': 'track'
    };
    var track = map.cv<DeezerTrack>();
    expect(track.id.v, '3135556');
    expect(track.preview.v,
        'https://cdns-preview-d.dzcdn.net/stream/c-deda7fa9316d9e9e880d2c6207e92260-10.mp3');
    expect(track.title.v, 'Harder, Better, Faster, Stronger');
    var artist = track.artist.v!;
    expect(artist.id.v, '27');
    expect(artist.name.v, 'Daft Punk');
    var album = track.album.v!;
    expect(album.id.v, '302127');
    expect(album.title.v, 'Discovery');
    expect(album.coverMedium.v,
        'https://e-cdns-images.dzcdn.net/images/cover/2e018122cb56986277102d2041a592c8/250x250-000000-80-0-0.jpg');
  });
  test('user', () {
    var map = {
      'id': '513005798278',
      'name': 'Some user',
      'lastname': '',
      'firstname': '',
      'email': '',
      'status': 2,
      'birthday': '0000-00-00',
      'inscription_date': '2022-09-25',
      'gender': '',
      'link': 'https://www.deezer.com/profile/513005798278',
      'picture': 'https://api.deezer.com/user/513005798278/image',
      'picture_small':
          'https://e-cdns-images.dzcdn.net/images/user//56x56-000000-80-0-0.jpg',
      'picture_medium':
          'https://e-cdns-images.dzcdn.net/images/user//250x250-000000-80-0-0.jpg',
      'picture_big':
          'https://e-cdns-images.dzcdn.net/images/user//500x500-000000-80-0-0.jpg',
      'picture_xl':
          'https://e-cdns-images.dzcdn.net/images/user//1000x1000-000000-80-0-0.jpg',
      'country': 'FR',
      'lang': 'FR',
      'is_kid': false,
      'explicit_content_level': 'explicit_display',
      'explicit_content_levels_available': [
        'explicit_display',
        'explicit_no_recommendation',
        'explicit_hide'
      ],
      'tracklist': 'https://api.deezer.com/user/513005798278/flow',
      'type': 'user'
    };
    var user = map.cv<DeezerUser>();
    expect(user.id.v, '513005798278');
    expect(user.name.v, 'Some user');
  });
  test('error', () {
    // no auth token
    var map = {
      'error': {
        'type': 'OAuthException',
        'message':
            'An active access token must be used to query information about the current user',
        'code': 200
      }
    };
    var error = map.cv<DeezerError>();
    expect(error.error.v!.type.v, 'OAuthException');
    expect(error.error.v!.message.v,
        'An active access token must be used to query information about the current user');
    expect(error.error.v!.code.v, 200);
  });
  test('DeezerAppInfo', () {
    expect(fillModel<DeezerAppInfo>(),
        {'id': 'text_1', 'secretKey': 'text_2', 'domain': 'text_3'});
  });

  test('playlist', () {
    var playlist = simplePlaylistJson.cv<DeezerPlaylist>();
    expect(playlist.id.v, '260764721');
    expect(playlist.title.v, '1 item');
    expect(playlist.picture.v,
        'http://api.deezer.com/2.0/playlist/260764721/image');
    var tracks = playlist.tracks.v!.list.v!;
    expect(tracks.length, 1);
    var track = tracks.first;
    expect(track.id.v, '937330');
    expect(track.title.v, 'Oxford Comma');
    expect(track.preview.v,
        'http://cdn-preview-4.deezer.com/stream/c-4411fdd67515862edaa32086ca1efb1e-8.mp3');
    expect(track.artist.v!.id.v, '75781');
    expect(track.artist.v!.name.v, 'Vampire Weekend');

    playlist = playlist.toMap().cv<DeezerPlaylist>();
    expect(playlist.toMap(), {
      'id': '260764721',
      'title': '1 item',
      'description': '',
      'picture': 'http://api.deezer.com/2.0/playlist/260764721/image',
      'picture_small':
          'http://cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/56x56-000000-80-0-0.jpg',
      'picture_medium':
          'http://cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/250x250-000000-80-0-0.jpg',
      'tracks': {
        'data': [
          {
            'id': '937330',
            'title': 'Oxford Comma',
            'preview':
                'http://cdn-preview-4.deezer.com/stream/c-4411fdd67515862edaa32086ca1efb1e-8.mp3',
            'artist': {'id': '75781', 'name': 'Vampire Weekend'},
            'album': {
              'id': '105411',
              'title': 'Vampire Weekend',
              'cover_small':
                  'http://cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/56x56-000000-80-0-0.jpg',
              'cover_medium':
                  'http://cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/250x250-000000-80-0-0.jpg'
            }
          }
        ]
      }
    });
  });
}

// http://api.deezer.com/2.0/playlist/260764721?output=jsonp
var simplePlaylistJson = {
  'id': 260764721,
  'title': '1 item',
  'description': '',
  'duration': 195,
  'public': true,
  'is_loved_track': false,
  'collaborative': false,
  'nb_tracks': 1,
  'fans': 0,
  'link': 'http://www.deezer.com/playlist/260764721',
  'share':
      'https://www.deezer.com/playlist/260764721?utm_source=deezer&utm_content=playlist-260764721&utm_term=0_1628777376&utm_medium=web',
  'picture': 'http://api.deezer.com/2.0/playlist/260764721/image',
  'picture_small':
      'http://cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/56x56-000000-80-0-0.jpg',
  'picture_medium':
      'http://cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/250x250-000000-80-0-0.jpg',
  'picture_big':
      'http://cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/500x500-000000-80-0-0.jpg',
  'picture_xl':
      'http://cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/1000x1000-000000-80-0-0.jpg',
  'checksum': 'ad120380240513450c02797a7b333008',
  'tracklist': 'http://api.deezer.com/2.0/playlist/260764721/tracks',
  'creation_date': '2013-11-06 18:00:00',
  'md5_image': 'aace835cee2c52614f55282b6081e5c6',
  'picture_type': 'cover',
  'creator': {
    'id': 152687221,
    'name': 'tekartik',
    'tracklist': 'http://api.deezer.com/2.0/user/152687221/flow',
    'type': 'user'
  },
  'type': 'playlist',
  'tracks': {
    'data': [
      {
        'id': 937330,
        'readable': true,
        'title': 'Oxford Comma',
        'title_short': 'Oxford Comma',
        'title_version': '',
        'link': 'http://www.deezer.com/track/937330',
        'duration': 195,
        'rank': 492659,
        'explicit_lyrics': true,
        'explicit_content_lyrics': 1,
        'explicit_content_cover': 2,
        'preview':
            'http://cdn-preview-4.deezer.com/stream/c-4411fdd67515862edaa32086ca1efb1e-8.mp3',
        'md5_image': 'aace835cee2c52614f55282b6081e5c6',
        'time_add': 1363721188,
        'artist': {
          'id': 75781,
          'name': 'Vampire Weekend',
          'link': 'http://www.deezer.com/artist/75781',
          'tracklist': 'http://api.deezer.com/2.0/artist/75781/top?limit=50',
          'type': 'artist'
        },
        'album': {
          'id': 105411,
          'title': 'Vampire Weekend',
          'cover': 'http://api.deezer.com/2.0/album/105411/image',
          'cover_small':
              'http://cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/56x56-000000-80-0-0.jpg',
          'cover_medium':
              'http://cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/250x250-000000-80-0-0.jpg',
          'cover_big':
              'http://cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/500x500-000000-80-0-0.jpg',
          'cover_xl':
              'http://cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/1000x1000-000000-80-0-0.jpg',
          'md5_image': 'aace835cee2c52614f55282b6081e5c6',
          'tracklist': 'http://api.deezer.com/2.0/album/105411/tracks',
          'type': 'album'
        },
        'type': 'track'
      }
    ],
    'checksum': 'ad120380240513450c02797a7b333008'
  }
};

var simpleJsonPlaylistTracks1 = {
  'data': [
    {
      'id': 937330,
      'readable': true,
      'title': 'Oxford Comma',
      'title_short': 'Oxford Comma',
      'title_version': '',
      'link': 'https://www.deezer.com/track/937330',
      'duration': 195,
      'rank': 463680,
      'explicit_lyrics': true,
      'explicit_content_lyrics': 1,
      'explicit_content_cover': 2,
      'preview':
          'https://cdns-preview-1.dzcdn.net/stream/c-128660c09ef7373f9919e2150cc4a7bd-3.mp3',
      'md5_image': '6fc963e3e5bd489dd82b0e02c3122792',
      'time_add': 1363721188,
      'artist': {
        'id': 75781,
        'name': 'Vampire Weekend',
        'link': 'https://www.deezer.com/artist/75781',
        'picture': 'https://api.deezer.com/2.0/artist/75781/image',
        'picture_small':
            'https://e-cdns-images.dzcdn.net/images/artist/9e6559537b6a3419e4956b3222862ab7/56x56-000000-80-0-0.jpg',
        'picture_medium':
            'https://e-cdns-images.dzcdn.net/images/artist/9e6559537b6a3419e4956b3222862ab7/250x250-000000-80-0-0.jpg',
        'picture_big':
            'https://e-cdns-images.dzcdn.net/images/artist/9e6559537b6a3419e4956b3222862ab7/500x500-000000-80-0-0.jpg',
        'picture_xl':
            'https://e-cdns-images.dzcdn.net/images/artist/9e6559537b6a3419e4956b3222862ab7/1000x1000-000000-80-0-0.jpg',
        'tracklist': 'https://api.deezer.com/2.0/artist/75781/top?limit=50',
        'type': 'artist'
      },
      'album': {
        'id': 105411,
        'title': 'Vampire Weekend',
        'cover': 'https://api.deezer.com/2.0/album/105411/image',
        'cover_small':
            'https://e-cdns-images.dzcdn.net/images/cover/6fc963e3e5bd489dd82b0e02c3122792/56x56-000000-80-0-0.jpg',
        'cover_medium':
            'https://e-cdns-images.dzcdn.net/images/cover/6fc963e3e5bd489dd82b0e02c3122792/250x250-000000-80-0-0.jpg',
        'cover_big':
            'https://e-cdns-images.dzcdn.net/images/cover/6fc963e3e5bd489dd82b0e02c3122792/500x500-000000-80-0-0.jpg',
        'cover_xl':
            'https://e-cdns-images.dzcdn.net/images/cover/6fc963e3e5bd489dd82b0e02c3122792/1000x1000-000000-80-0-0.jpg',
        'md5_image': '6fc963e3e5bd489dd82b0e02c3122792',
        'tracklist': 'https://api.deezer.com/2.0/album/105411/tracks',
        'type': 'album'
      },
      'type': 'track'
    }
  ],
  'checksum': 'ad120380240513450c02797a7b333008',
  'total': 1
};
