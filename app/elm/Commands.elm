module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline exposing (decode, required)
import Images.Models exposing (Image, Person, ImagesContainerModel)
import RemoteData exposing (WebData)


loadImages : (WebData (List Image) -> msg) -> Cmd msg
loadImages msg =
    Http.get "images.json" imagesDecoder
        |> RemoteData.sendRequest
        |> Cmd.map msg


loadPeople : (WebData (List Person) -> msg) -> Cmd msg
loadPeople msg =
    Http.get "people.json" peopleDecoder
        |> RemoteData.sendRequest
        |> Cmd.map msg


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
