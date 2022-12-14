//
//  ApproveUserProtocol.swift
//  Pitaza170
//
//  Created by Артем Тихонов on 20.11.2022.
//

import Foundation

protocol ApproveUserProtocol: AnyObject {
    
    func approveUser(id: Int, clouser: (() -> Void)?)
    
    func rejectUser(id: Int, clouser: (() -> Void)?)
}
