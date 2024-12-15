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
    weak var coordinator: WorkspaceCoordinator?
    
    init(reactor: WorkspaceListReactor) {
        super.init()
        self.reactor = reactor
    }
    
    deinit {
        print("DEBUG: \(String(describing: self)) deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setuPenGesture()
        setupNotification()
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
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismissed), name: .workspaceEditComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalDismissed), name: .workspaceChangeAdminComplete, object: nil)
    }
    
    //MARK: - Methods
    
    func bind(reactor: WorkspaceListReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    //워크스페이스 목록 화면(containerView)을 화면 밖에서부터 안쪽으로 이동시키기(이동방향: 왼쪽 -> 오른쪽)
    private func fadeIn(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0, animations: { [weak self] in
            guard let self else { return }
            self.rootView.containerView.frame.origin.x = 0 //화면 안으로 이동
        }, completion: { _ in
            completion?()
        })
    }
    
    //워크스페이스 목록 화면(containerView)을 화면 왼쪽 밖으로 이동시키기(이동방향: 오른쪽 -> 왼쪽)
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
                    guard let self else { return }
                    self.coordinator?.didFinishWorkspaceList()
                    self.coordinator?.didFinish()
                }
            } else { // 오른쪽으로 드래그하거나 멈춘 경우
                fadeIn()
            }
        default:
            break
        }
    }
    
    @objc private func handleModalDismissed() {
        reactor?.action.onNext(.fetch)
    }
}

//MARK: - Bind Action

extension WorkspaceListViewController {
    private func bindAction(reactor: WorkspaceListReactor) {
        rootView.shadowBackViewRxTap
            .map { Reactor.Action.shadowAreaTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rx.methodInvoked(#selector(viewWillAppear(_:)))
            .map { _ in Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.workspaceAddButton.rx.tap
            .map { Reactor.Action.createButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        rootView.tableView.rx.modelSelected(Workspace.self)
            .map { Reactor.Action.selectWorkspace($0) }
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
        
        let workspaceListStream = reactor.pulse(\.$workspaceList)
            .compactMap { $0 }
            .share()
        
        workspaceListStream
            .map { !$0.isEmpty }
            .bind(to: rootView.emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        workspaceListStream
            .bind(to: rootView.tableView.rx.items(cellIdentifier: WorkspaceListTableViewCell.reuseIdentifier, cellType: WorkspaceListTableViewCell.self)) { [weak self] row, element, cell in
                guard let self else { return }
                cell.configureCell(data: element)
                cell.selectionStyle = .none
                
                cell.menuButton.rx.tap
                    .bind(with: self) { owner, _ in
                        if element.ownerID == UserDefaultsManager.shared.userID ?? "" {
                            //관리자인 경우
                            owner.showActionSheet(actions: [
                                //액션시트 편집
                                ("워크스페이스 편집", UIAlertAction.Style.default, {
                                    owner.coordinator?.showWorkspaceEdit(viewController: owner, workspace: element)
                                }),
                                //액션시트 나가기
                                ("워크스페이스 나가기", UIAlertAction.Style.default, {
                                    //얼럿으로 사용자에게 재확인 요청
                                    owner.showAlert(title: "채널 나가기", message: "정말 해당 채널을 나가시겠습니까?", actions: [
                                        ("나가기", {
                                            owner.reactor?.action.onNext(.selectWorkspaceExitActionSheet)
                                        })
                                    ])
                                }),
                                //액션시트 관리자 변경
                                ("워크스페이스 관리자 변경", UIAlertAction.Style.default, {
                                    owner.reactor?.action.onNext(.selectWorkspaceChangeAdminActionSheet)
                                }),
                                //액션시트 삭제
                                ("워크스페이스 삭제", UIAlertAction.Style.destructive, {
                                    //얼럿으로 사용자에게 재확인 요청
                                    owner.showAlert(title: "워크스페이스 삭제", message: "정말 이 워크스페이스를 삭제하시겠습니까? 삭제 시 채널/멤버/채팅 등 워크스페이스 내의 모든 정보가 삭제되며 복구할 수 없습니다.", actions: [
                                        ("삭제", { owner.reactor?.action.onNext(.selectWorkspaceDeleteActionSheet) })
                                    ])
                                })
                            ])
                        } else {
                            //관리자아닌 경우
                            //액션시트 나가기
                            owner.showActionSheet(actions: [
                                ("워크스페이스 나가기", UIAlertAction.Style.default, {
                                    //얼럿으로 사용자에게 재확인 요청
                                    owner.showAlert(title: "채널 나가기", message: "정말 해당 채널을 나가시겠습니까?", actions: [
                                        ("나가기", {
                                            owner.reactor?.action.onNext(.selectWorkspaceExitActionSheet)
                                        })
                                    ])
                                }),
                            ])
                        }
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$navigateToHome)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.fadeOut {
                    owner.coordinator?.didFinishWorkspaceList()
                    owner.coordinator?.didFinish()
                }
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$navigateToWorkspaceAdd)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.coordinator?.didFinishWorkspaceList()
                owner.coordinator?.showWorkspaceAdd(previousScreen: .workspaceList)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$navigateToWorkspaceChangeAdmin)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.coordinator?.showWorkspaceChangeAdmin(viewController: owner)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$showRetryDeleteChannelChatRealmDBAlert)
            .compactMap { $0 }
            .bind(with: self) { owner, _ in
                owner.showAlert(title: "데이터 정리 실패", message: "삭제한 워크스페이스 관련 데이터 제거가 실패되었습니다. 다시 시도하시겠습니까?", actions: [
                    ("재시도", { owner.reactor?.action.onNext(.selectRetryAction) })
                ]) {
                    owner.reactor?.action.onNext(.selectRetryCancelAction)
                }
            }
            .disposed(by: disposeBag)
    }
}
