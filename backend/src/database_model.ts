type AnnotationJobDb = {
    id: string,
    CreatedOn: string,
    ImageFileName: string
}

type AnnotationDb = {
    id: string,
    AnnotatedOn: string,
    ServerReceivedOn: string,
    AnnotationJobID: string,
    BoundingBoxes: string,
}

export type {AnnotationJobDb, AnnotationDb};