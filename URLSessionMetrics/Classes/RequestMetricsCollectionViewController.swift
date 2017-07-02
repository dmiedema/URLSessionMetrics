//
//  RequestMetricsCollectionView.swift
//  URLSessionMetrics
//
//  Created by Daniel Miedema on 6/16/16.
//  Copyright © 2016 dmiedema. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
/// Collection View Controller for displaying basic Request Metrics
public class RequestMetricsCollectionViewController: UICollectionViewController {
    private let CellReuseIdentifier  = "RequestMetricsCollectionViewController.CellReuseIdentifier"
    private let HeaderReuseIdentifier = "RequestMetricsCollectionViewController.HeaderReuseIdentifier"

    /// Our default
    public var metricsManager = DefaultMetricsManager.shared

    /// Requests organized by host.
    /// Each array will be grouped by the host and then internally sorted by newest request first.
    /// For example, if we have requests to `google.com` and `youtube.com` we'll have 2 sub arrays
    /// `[[Requests to Google], [Requests to YouTube]]`
    private var requestMetrics = [[URLSessionTaskMetrics]]()

    /// Helper function for automatically embedding the collection view
    /// inside of a `UINavigationController`.
    /// - returns: `UINavigationController` with the `RequestMetricsCollectionViewController` as its root controller
    public class func requestMetricsCollectionView() -> UINavigationController {
        let layout = UICollectionViewFlowLayout()
        let controller = RequestMetricsCollectionViewController(collectionViewLayout: layout)
        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }

    //MARK: - View Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .lightGray

        collectionView?.register(RequestMetricsCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: CellReuseIdentifier)
        collectionView?.register(RequestMetricsCollectionViewHeader.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderReuseIdentifier)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(RequestMetricsCollectionViewController.closeViewController))

        title = "Network Requests"
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(RequestMetricsCollectionViewController.refresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    //MARK: - Actions
    @objc func closeViewController() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func refresh() {
        var organized: [String : [URLSessionTaskMetrics]] = [:]

        for metric in metricsManager.metrics {
            var metrics = organized[metric.requestURL?.url?.host ?? "Unknown Host"] ?? []
            metrics.append(metric)
            organized[metric.requestURL?.url?.host ?? "Unknown Host"] = metrics
        }
        requestMetrics = organized.flatMap({ (dict) in
            return dict.value.sorted(by: { (task1, task2) -> Bool in
                guard let task1Start = task1.transactionMetrics.first?.fetchStartDate,
                    let task2Start = task2.transactionMetrics.first?.fetchStartDate else {
                        return false
                }
                return task1Start > task2Start
            })
        })

        collectionView?.reloadData()
        collectionView?.refreshControl?.endRefreshing()
    }

    //MARK: - UICollectionViewDelegate
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let metrics = requestMetrics[indexPath.section][indexPath.row]
        let controller = RequestMetricsDetailView(metrics: metrics)
        navigationController?.pushViewController(controller, animated: true)
    }

    //MARK: - UICollectionViewDatasource
    override public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader,
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderReuseIdentifier, for: indexPath) as? RequestMetricsCollectionViewHeader
            else {
            return UICollectionReusableView()
        }
        header.requestBaseLabel.text = requestMetrics[indexPath.section].first?.requestURL?.url?.host ?? "Unknown Host"
        return header
    }

    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return requestMetrics.count
    }

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return requestMetrics[section].count
    }

    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellReuseIdentifier, for: indexPath) as? RequestMetricsCollectionViewCell else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: CellReuseIdentifier, for: indexPath)
        }
        cell.configure(metrics: requestMetrics[indexPath.section][indexPath.row])

        return cell
    }

    override public func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

@available(iOS 10.0, *)
/// Hacky way to show two cells side by side when running in `regular` horiztonal size class
extension RequestMetricsCollectionViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat
        if collectionView.traitCollection.horizontalSizeClass == .regular {
            width = (collectionView.frame.size.width / 2.0) - 20
        } else {
            width = collectionView.frame.size.width
        }
        return CGSize(width: width, height: 120)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 30)
    }
}
