module Commands exposing (..)

import Http
import Messages exposing (Msg)
import Json.Decode as Decode
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline exposing (decode, required)
import Images.Models exposing (Image, Person, ImagesContainerModel)
import RemoteData


loadData : Cmd Msg
loadData =
    Cmd.batch [ loadImages, loadPeople ]


loadImages : Cmd Msg
loadImages =
    Http.get "images.json" imagesDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Messages.OnLoadImages


loadPeople : Cmd Msg
loadPeople =
    Http.get "people.json" peopleDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Messages.OnLoadPeople


peopleDecoder : Decode.Decoder (List Person)
peopleDecoder =
    Decode.field "people" <| Decode.list personDecoder


personDecoder : Decode.Decoder Person
personDecoder =
    decode Person
        |> required "id" Decode.int
        |> required "name" Decode.string


imagesDecoder : Decode.Decoder (List Image)
imagesDecoder =
    Decode.field "images" <| Decode.list imageDecoder


imageDecoder : Decode.Decoder Image
imageDecoder =
    decode Image
        |> required "id" Decode.int
        |> required "description" Decode.string
        |> required "dateAdded" DecodeExtra.date
        |> required "thumbnail" Decode.string
        |> required "fullsize" Decode.string
        |> required "download" Decode.string
        |> required "people" (Decode.list Decode.int)
