//
//  Copyright © 2018 Matyushenko Maxim. All rights reserved.
//

import RxSwift
import RxFeedback

protocol RatesSideEffects: SideEffects {
    /// Получение курсов валют.
    var acquireRates: () -> Observable<SideEffects.State.Event> { get }
    /// Открытие экрана редактирования списка валют.
    var openEditMode: () -> Observable<SideEffects.State.Event> { get }
    /// Закрытие экрана редактирования списка валют.
    var closeEditMode: () -> Observable<SideEffects.State.Event> { get }
}

extension RatesSideEffects {
    var effects: [SideEffects.ScheduledEffect] {
        return [
            react(query: { $0.rates.queryAcquireRates }, effects: acquireRates),
            react(query: { $0.rates.queryOpenEditMode }, effects: openEditMode),
            react(query: { $0.rates.queryCloseEditMode }, effects: closeEditMode)
        ]
    }
}

struct RatesSideEffectsImpl: RatesSideEffects {
    
    private let _services: AppServices
    private let _coordinator: SceneCoordinator
    private let _backgroundScheduler: SchedulerType
    
    
    init(services: AppServices,
         coordinator: SceneCoordinator,
         backgroundScheduler: SchedulerType) {
        _services = services
        _coordinator = coordinator
        _backgroundScheduler = backgroundScheduler
    }
    
    var acquireRates: () -> Observable<SideEffects.State.Event> {
        return {
            self._services.ratesService
                .rates(on: Date())
                .map { .rates(.ratesResult($0)) }
                .subscribeOn(self._backgroundScheduler)
        }
    }
    
    var openEditMode: () -> Observable<SideEffects.State.Event> {
        return { self._coordinator
            .transition(to: .editRates, type: .modal(animated: true))
            .map { .rates(.editModeOpened) }
        }
    }
    
    var closeEditMode: () -> Observable<SideEffects.State.Event> {
        return {
            self._coordinator.pop(animated: true)
                .map { .rates(.editModeClosed) }
        }
    }
}
