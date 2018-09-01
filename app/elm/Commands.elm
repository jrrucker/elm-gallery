module Commands exposing (encodeImage, imageDecoder, imagesDecoder, imgLayoutDecoder, layoutDecoder, loadImages, loadPeople, peopleDecoder, personDecoder)

import Http
import Images.Models exposing (Image, ImagesContainerModel, ImgLayout, Layout, Person)
import Json.Decode as Decode
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Task exposing (Task)


loadImages : String -> Task Http.Error (List Image)
loadImages albumPath =
    Http.get (albumPath ++ "/images.json") imagesDecoder
        |> Http.toTask


loadPeople : String -> Task Http.Error (List Person)
loadPeople albumPath =
    Http.get (albumPath ++ "/people.json") peopleDecoder
        |> Http.toTask


peopleDecoder : Decode.Decoder (List Person)
peopleDecoder =
    Decode.field "people" <| Decode.list personDecoder


personDecoder : Decode.Decoder Person
personDecoder =
    Decode.succeed Person
        |> required "id" Decode.int
        |> required "name" Decode.string


imagesDecoder : Decode.Decoder (List Image)
imagesDecoder =
    Decode.field "images" <| Decode.list imageDecoder


imageDecoder : Decode.Decoder Image
imageDecoder =
    Decode.succeed Image
        |> required "id" Decode.int
        |> required "description" Decode.string
        |> required "dateAdded" DecodeExtra.datetime
        |> required "thumbnail" Decode.string
        |> required "fullsize" Decode.string
        |> required "download" Decode.string
        |> required "people" (Decode.list Decode.int)
        |> required "width" Decode.int
        |> required "height" Decode.int


encodeImage : Image -> Encode.Value
encodeImage image =
    Encode.object
        [ ( "id", Encode.int image.id )
        , ( "description", Encode.string image.description )
        , ( "thumbnail", Encode.string image.thumbnail )
        , ( "fullsize", Encode.string image.fullsize )
        , ( "download", Encode.string image.download )
        , ( "people", Encode.list Encode.int image.people )
        , ( "width", Encode.int image.width )
        , ( "height", Encode.int image.height )
        ]


layoutDecoder : Decode.Decoder Layout
layoutDecoder =
    Decode.succeed Layout
        |> required "containerHeight" Decode.float
        |> required "widowCount" Decode.int
        |> required "boxes" (Decode.list imgLayoutDecoder)


imgLayoutDecoder : Decode.Decoder ImgLayout
imgLayoutDecoder =
    Decode.succeed ImgLayout
        |> required "aspectRatio" Decode.float
        |> required "top" Decode.float
        |> required "left" Decode.float
        |> required "width" Decode.float
        |> required "height" Decode.float
