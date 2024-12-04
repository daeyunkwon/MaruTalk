//
//  WorkspaceListViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 12/3/24.
//

import UIKit

import ReactorKit
import RxCocoa
import SnapKit

final class WorkspaceListViewController: BaseViewController<WorkspaceListView>, View {
    
    //MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: HomeCoordinator?
    
    init(reactor: WorkspaceListReactor) {
        super.init()
        self.reactor = reactor
    }
    
    deinit {
        print("DEBUG: \(String(describing: self)) deinit")
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setuPenGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fadeIn {
            NotificationCenter.default.post(name: .workspaceListViewFadeInComplete, object: nil)
        }
    }
    
    //MARK: - Configurations
    
    private func setuPenGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        rootView.containerView.addGestureRecognizer(panGesture)
    }
    
    //MARK: - Methods
    
    func bind(reactor: WorkspaceListReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func fadeIn(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0, animations: { [weak self] in
            guard let self else { return }
            self.rootView.containerView.frame.origin.x = 0 //화면 안으로 이동
        }, completion: { _ in
            completion?()
        })
    }
    
    private func fadeOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            let width = self.rootView.bounds.width - (self.rootView.bounds.width / 4) //화면 왼쪽 밖으로 이동
            self.rootView.containerView.frame.origin.x = -width
        } completion: { _ in
            completion?()
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: rootView)
        let velocity = gesture.velocity(in: rootView)
        
        switch gesture.state {
        case .changed:
            // 드래그에 따라 뷰의 x 좌표 업데이트
            let newX = max(-300, min(0, translation.x)) //x좌표 이동 범위를 -300 ~ 0으로 제한
            rootView.containerView.frame.origin.x = newX
            
        case .ended:
            // 드래그 종료 시 뷰 위치 결정
            print(velocity)
            if velocity.x < 0 { // 왼쪽으로 드래그한 경우
                fadeOut { [weak self] in
                    self?.coordinator?.didFinishWorkspaceList()
                }
            } else { // 오른쪽으로 드래그하거나 멈춘 경우
                fadeIn()
            }
        default:
            break
        }
    }
}

//MARK: - Bind Action

extension WorkspaceListViewController {
    private func bindAction(reactor: WorkspaceListReactor) {
        rootView.shadowBackViewRxTap
            .bind(with: self) { owner, _ in
                owner.fadeOut {
                    owner.coordinator?.didFinishWorkspaceList()
                }
            }
            .disposed(by: disposeBag)
        
        rx.methodInvoked(#selector(viewWillAppear(_:)))
            .map { _ in Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.workspaceAddButton.rx.tap
            .map { Reactor.Action.createButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

//MARK: - Bind State

extension WorkspaceListViewController {
    private func bindState(reactor: WorkspaceListReactor) {
        reactor.pulse(\.$networkError)
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                owner.showToastForNetworkError(api: value.0, errorCode: value.1)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$workspaceList)
            .compactMap { $0 }
            .map { !$0.isEmpty }
            .bind(to: rootView.emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$workspaceList)
            .compactMap { $0 }
            .bind(to: rootView.tableView.rx.items(cellIdentifier: WorkspaceListTableViewCell.reuseIdentifier, cellType: WorkspaceListTableViewCell.self)) { row, element, cell in
                cell.configureCell(data: element)
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldNavigateToWorkspaceAdd)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishWorkspaceList()
                owner.coordinator?.showWorkspaceAdd(previousScreen: .workspaceList)
            }
            .disposed(by: disposeBag)
    }
}
