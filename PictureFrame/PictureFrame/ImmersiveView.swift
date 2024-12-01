//
//  ImmersiveView.swift
//  PictureFrame
//
//  Created by namu.kim on 12/1/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

@MainActor
struct ImmersiveView: View {

    @State private var frame = Entity()
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "FrameScene", in: realityKitContentBundle) {
                content.add(scene)

                guard let frame = scene.findEntity(named: "Frame") else {
                    fatalError()
                }

                self.frame = frame
                frame.position = [1, 1.5, -1.5]
                frame.transform.rotation = simd_quatf(angle: -.pi/2, axis: [0,1,0])

                //
                let world1 = Entity()
                world1.components.set(WorldComponent())
                let skybox1 = await createSkyBoxEntity(texture: "sunflowers_puresky_8k")
                world1.addChild(skybox1)
                content.add(world1)
                
                //
                let world1Portal = createPotal(target: world1)
                content.add(world1Portal)
                
                guard let anchorPortal1 = scene.findEntity(named: "Anchor") else {
                    fatalError("Cannot find portal anchor")
                }
                
                anchorPortal1.addChild(world1Portal)
                anchorPortal1.transform.rotation = simd_quatf(angle: .pi/2, axis: [1,0,0])
                
                //
                if let world1Scene = try? await Entity(named: "WorldScene", in:realityKitContentBundle) {
                    world1Scene.position = [0, 2, 0]
                    world1.addChild(world1Scene)
                }
                
            }
        }
    }
    
    func createSkyBoxEntity(texture: String) async -> Entity{
        guard let resource = try? await TextureResource(named: texture) else {
            fatalError("Unable to load the skybox")
        }
        
        var material = UnlitMaterial()
        material.color = .init(texture: .init(resource))
        
        let entity = Entity()
        entity.components.set(ModelComponent(mesh: .generateSphere(radius: 1000), materials: [material]))
        entity.scale *= .init(x: -1, y:1, z:1)
        return entity
    }
    
    func createPotal(target: Entity) -> Entity {
        let portalMesh = MeshResource.generatePlane(width:1, depth:1)
        let portal = ModelEntity(mesh: portalMesh, materials: [PortalMaterial()])
        portal.components.set(PortalComponent(target: target))
        return portal
    }
    
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
