//
//  HomeViewController.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/14/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxDataSources

final class HomeViewController: BaseViewController<HomeView>, View {
    
    //MARK: - Properties
    
    weak var coordinator: HomeCoordinator?
    var disposeBag = DisposeBag()
    private var sections: [SectionModel] = []
    
    private let reactor: HomeReactor
    
    init(reactor: HomeReactor) {
        self.reactor = reactor
        super.init()
    }
    
    private let profileCircleView = ProfileCircleView()
    private let workspaceNameView = RoundedImageTitleView()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(reactor: reactor)
        reactor.action.onNext(.checkWorkspace)
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: workspaceNameView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileCircleView)
        
    }
    
    //MARK: - Methods
    
    func bind(reactor: HomeReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindTableView(reactor: reactor)
    }
}

//MARK: - BindAction

extension HomeViewController {
    private func bindAction(reactor: HomeReactor) {
            
        
        
        profileCircleView.rxTap
            .bind(with: self) { owner, _ in
                print(11111)
                owner.workspaceNameView.backgroundColor = .red
                owner.tabBarController?.tabBar.isHidden = true
                owner.rootView.emptyView.isHidden = false
            }
            .disposed(by: disposeBag)
        
        workspaceNameView.rxTap
            .bind(with: self) { owner, _ in
                print(22222)
                owner.tabBarController?.tabBar.isHidden = false
                owner.rootView.emptyView.isHidden = true
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - BindState

extension HomeViewController {
    private func bindState(reactor: HomeReactor) {
        reactor.state.map { $0.isShowEmpty }
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                if value {
                    owner.rootView.emptyView.isHidden = false
                    owner.tabBarController?.tabBar.isHidden = true
                } else {
                    owner.rootView.emptyView.isHidden = true
                    owner.tabBarController?.tabBar.isHidden = false
                }
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - BindTableView

extension HomeViewController {
    private func bindTableView(reactor: HomeReactor) {
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionModel>(
            configureCell: { _, tableView, indexPath, item in
                switch item {
                case .channel(let text):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: HashTitleCountTableViewCell.reuseIdentifier, for: indexPath) as? HashTitleCountTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.configure(title: text)
                    return cell
                
                case .dm(let text):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageTitleCountTableViewCell.reuseIdentifier, for: indexPath) as? ImageTitleCountTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.configure(title: text)
                    return cell
                    
                case .add(let text):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: PlusTitleTableViewCell.reuseIdentifier, for: indexPath) as? PlusTitleTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.configure(title: text)
                    return cell
                }
            }
        )
        
        reactor.state.map { $0.sections }
            .bind(to: rootView.tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        rootView.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.sections }
            .distinctUntilChanged()
            .bind(with: self, onNext: { owner, value in
                owner.sections = value
                
                guard let channel = owner.rootView.tableView.headerView(forSection: 0) as? DropdownArrowTableViewCell else {
                    return
                }
                
                channel.configure(title: owner.sections[0].headerTitle, isExpanded: owner.sections[0].isExpanded)
                
                guard let dm = owner.rootView.tableView.headerView(forSection: 1) as? DropdownArrowTableViewCell else {
                    return
                }
                
                dm.configure(title: owner.sections[1].headerTitle, isExpanded: owner.sections[1].isExpanded)
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0, 1:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: DropdownArrowTableViewCell.reuseIdentifier) as? DropdownArrowTableViewCell else {
                return nil
            }
            
            headerView.section = section
            headerView.delegate = self
            
            let section = self.sections[section]
            headerView.configure(title: section.headerTitle, isExpanded: section.isExpanded)
            
            return headerView
            
        case 2:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: PlusTitleHeaderTableViewCell.reuseIdentifier) as? PlusTitleHeaderTableViewCell else {
                return nil
            }
            headerView.delegate = self
            headerView.configure(title: self.sections[section].headerTitle)
            return headerView
            
        default: return nil
        }
    }
}

//MARK: - DropdownArrowTableViewCellDelegate

extension HomeViewController: DropdownArrowTableViewCellDelegate {
    func sectionHeaderTapped(section: Int) {
        reactor.action.onNext(.sectionTapped(section))
    }
}

//MARK: - PlusTitleHeaderTableViewCellDelegate

extension HomeViewController: PlusTitleHeaderTableViewCellDelegate {
    func cellTapped() {
        print(#function)
    }
}
